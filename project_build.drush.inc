<?php
/**
 * @file
 * Drush provision wrapper to simplify large scale site deployment.
 */

/**
 * Implements hook_drush_command().
 */
function project_build_drush_command() {
  $items = array();
  $items['project-build'] = array(
    'description' => dt('Build a new instance of a site.'),
    'bootstrap' => DRUSH_BOOTSTRAP_DRUSH,
    'arguments'   => array(
      'source' => dt('The source of the database, one of "install", "clone" or "migrate". Defaults to "clone"'),
    ),
    'examples' => array(
      'Standard example' => 'drush project-build',
      'Argument example' => 'drush project-build install',
    ),
    'aliases' => array('b'),
  );
  return $items;
}

/**
 * Implements hook_drush_help().
 */
function project_build_drush_help($command) {
  switch ($command) {
    case 'drush:project-build':
    return dt('Build a new instance of a site.');
    break;
  }
}

/**
 * Callback for drush project build command.
 */
function drush_project_build($source = 'clone') {

  $provision_commands = _project_build_commands($source);

  // @TODO Invoke _alter here on the commands list.

  _project_build_execute_commands($provision_commands);

  return 0;
}

/**
 * Assemble the default list of provision commands to run.
 */
function _project_build_commands($source) {
  // @TODO Find a way to get rid of the global
  global $argv;

  if ('@' === $argv[1][0]) {
    $project_alias = $argv[1];
  }
  $project_info = drush_sitealias_get_record($project_alias);

  $provision_commands = array(
    'provision-save-platform' => array(
      'command' => 'provision-save platform_' . $project_info['platform_alias'],
      'command-args' => array(
        'context_type' => 'platform',
        'root' => $project_info['platform_root'],
        'makefile' => $project_info['makefile'],
      ),
    ),
    'provision-verify-platform' => array(
      'alias' => '@platform_' . $project_info['platform_alias'],
      'command' => 'provision-verify',
    ),
    'provision-save-site' => array(
      'command' => 'provision-save ' . $project_info['domain'],
      'command-args' => array(
        'uri' => $project_info['fulldomain'],
        'platform' => '@platform_' . $project_info['platform_alias'],
        'context_type' => 'site',
        'client_name' => 'admin',
        'server' => '@server_master',
        'db_server' => '@server_localhost',
        'profile' => $project_info['domain'],
        'aliases' => rtrim(implode($project_info['aliases'], ','), ','),
      ),
    ),
  );

  if ($source === 'clone') {
    // @TODO Implement
  }
  elseif ($source === 'install') {
    $provision_commands['provision-install'] = array(
      'alias' => '@' . $domain,
      'command' => 'drush @' . $project_info['domain'] . ' provision-install --debug',
      'exec' => TRUE,
    );
  }
  elseif ($source === 'migrate') {
    // @TODO Implement.
  }

  $provision_commands['provision-verify'] = array(
    'command' => 'provision-verify',
    'alias' => '@' . $site_alias,
  );

  return $provision_commands;
}

/**
 * Execute a list of provision commands.
 */
function _project_build_execute_commands($provision_commands) {
  $command_defaults = array(
    'command-args' => array(),
    'exec' => FALSE,
  );

  foreach ($provision_commands as $command) {
    $command = $command += $command_defaults;

    // Drush will return an empty array to signify FALSE, which we can't use.
    if (TRUE === drush_get_context('DRUSH_DEBUG')) {
      $command['command-args']['debug'] = TRUE;
    }

    if (TRUE === drush_get_context('DRUSH_DEBUG')) {
      build_humanly_readable($command);
    }

    $command['commands-args']['#interactive'] = TRUE;

    if (TRUE === $command['exec']) {
      run_shell_cmd($command['command'] . implode($command['command-args'], ' '));
    }
    elseif (isset($command['alias'])) {
      drush_invoke_process($command['alias'], $command['command'], $command['command-args']);
    }
    else {
      drush_backend_invoke($command['command'], $command['command-args']);
    }
  }
}

/**
 * Returns defaults for building.
 */
function _project_build_defaults() {
  $date_format = 'c';
  $public_dir = 'web-';
  $timestamp = date($date_format);

  return array();
}

/**
 * Convenience function for executing artibrary shell commands.
 */
function run_shell_cmd($cmd, $cwd = '.', $platform_relative_path = TRUE, $allow_fail = FALSE) {
  $path = $platform_relative_path ? d()->root . '/' . $cwd : $cwd;

  $cmd_ret = _build_drush_proc_open($cmd, NULL, NULL, $path);

  drush_log(dt($cmd_ret['output']));

  if ($cmd_ret['code'] !== 0) {
    $log_message = dt('The shell command @cmd failed with return value @code.', array(
      '@cmd' => $cmd_ret['cmd'],
      '@code' => $cmd_ret['code'],
    ));

    if ($allow_fail) {
      drush_log($log_message);
    }
    else {
      drush_set_error('SHELL_COMMAND_FAILED', $log_message);
    }
  }

  return $cmd_ret;
}

/**
 * Copy of drush's own proc_open that takes a $cwd parameter.
 */
function _build_drush_proc_open($cmd, $data = NULL, $context = NULL, $cwd = '.') {
  $descriptorspec = array(
    // Stdin is a pipe that the child will read from.
    0 => array('pipe', 'r'),
    // Stdout is a pipe that the child will write to.
    1 => array('pipe', 'w'),
    // Stderr is a pipe the child will write to.
    2 => array('pipe', 'w'),
  );
  if (drush_get_context('DRUSH_SIMULATE') && !array_key_exists('#override-simulated', $data)) {
    drush_print('proc_open: ' . $cmd);
    return FALSE;
  }
  $process = proc_open($cmd, $descriptorspec, $pipes, $cwd, NULL, array('context' => $context));
  if (is_resource($process)) {
    if ($data) {
      // Pass the data array in a JSON encoded string.
      fwrite($pipes[0], json_encode($data));
    }

    $info = stream_get_meta_data($pipes[1]);
    stream_set_blocking($pipes[1], TRUE);
    stream_set_timeout($pipes[1], 1);
    $string = '';
    while (!feof($pipes[1]) && !$info['timed_out']) {
      $string .= fgets($pipes[1], 4096);
      $info = stream_get_meta_data($pipes[1]);
      flush();
    };

    $info = stream_get_meta_data($pipes[2]);
    stream_set_blocking($pipes[2], TRUE);
    stream_set_timeout($pipes[2], 1);
    while (!feof($pipes[2]) && !$info['timed_out']) {
      $string .= fgets($pipes[2], 4096);
      $info = stream_get_meta_data($pipes[2]);
      flush();
    };

    fclose($pipes[0]);
    fclose($pipes[1]);
    fclose($pipes[2]);
    $code = proc_close($process);
    return array('cmd' => $cmd, 'output' => $string, 'code' => $code);
  }
  return FALSE;
}

/**
 * Function to output the intended command.
 *
 * @TODO See if there are internal Drush functions that can deal with this.
 */
function build_humanly_readable($command) {

  if (TRUE === $command['exec']) {
    drush_log($command['command'] . ' ' . implode($command['command-args'], ' '));
    return;
  }

  $output = 'drush ';

  if (isset($command['alias'])) {
    $output .= $command['alias'] . ' ';
  }

  $output .= $command['command'] . ' ';

  foreach ($command['command-args'] as $key => $value) {
    $output .= '--' . $key . '=' . $value . ' ';
  };

  $output .= PHP_EOL;

  drush_log($output);
}
