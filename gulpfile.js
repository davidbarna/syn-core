/*
 * Gulpfile
 * Tasks are registered from dev-tools module.
 */
devTools = require( 'dev-tools/gulp' );
manager = devTools.Manager.getInstance( require( 'gulp' ) );
manager.registerTasks();
