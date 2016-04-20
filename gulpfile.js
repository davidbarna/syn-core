/*
 * Gulpfile
 * Tasks are registered from dev-tools module.
 */
var devTools = require('syn-dev-tools').gulp
var manager = devTools.Manager.getInstance(require('gulp'))
manager.registerTasks()
