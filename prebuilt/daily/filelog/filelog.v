module filelog

import logx

[rotation: 'daily']
pub struct PrebuiltFileLog {
pub mut:
	trace_    logx.LevelInfo [cap: 10000; file: 'logs/trace/trace.log']
	debug_    logx.LevelInfo [cap: 9000; file: 'logs/debug/debug.log']
	info_     logx.LevelInfo [cap: 8000; file: 'logs/info/info.log']
	note_     logx.LevelInfo [cap: 7000; file: 'logs/note/note.log']
	warn_     logx.LevelInfo [cap: 1000; file: 'logs/warn/warn.log']
	alert_    logx.LevelInfo [cap: 1000; file: 'logs/alert/alert.log']
	error_    logx.LevelInfo [cap: 1000; file: 'logs/error/error.log']
	fatal_    logx.LevelInfo [cap: 1; file: 'logs/fatal/fatal.log']
	log_level int
	log_day  int // should be if [rotation: 'daily'] is set
}

pub enum LogLevel {
	trace
	debug
	info
	note
	warn
	alert
	error
	fatal
}

pub fn (mut l PrebuiltFileLog) wait() {
	logx.wait(mut l)
}

pub fn (mut l PrebuiltFileLog) set_level(level LogLevel) {
	l.log_level = int(level)
}

pub fn (mut l PrebuiltFileLog) trace(s string) {
	if l.log_level > int(LogLevel.trace) {
		return
	}
	logx.check_daily_rotation(mut l)
	l.trace_.ch <- l.trace_.formatter(s, 'TRACE')
}

pub fn (mut l PrebuiltFileLog) debug(s string) {
	if l.log_level > int(LogLevel.debug) {
		return
	}
	logx.check_daily_rotation(mut l)
	l.debug_.ch <- l.debug_.formatter(s, 'DEBUG')
}

pub fn (mut l PrebuiltFileLog) info(s string) {
	if l.log_level > int(LogLevel.info) {
		return
	}
	logx.check_daily_rotation(mut l)
	l.info_.ch <- l.info_.formatter(s, 'INFO ')
}

pub fn (mut l PrebuiltFileLog) note(s string) {
	if l.log_level > int(LogLevel.note) {
		return
	}
	logx.check_daily_rotation(mut l)
	l.note_.ch <- l.note_.formatter(s, 'NOTE ')
}

pub fn (mut l PrebuiltFileLog) warn(s string) {
	if l.log_level > int(LogLevel.warn) {
		return
	}
	logx.check_daily_rotation(mut l)
	l.warn_.ch <- l.warn_.formatter(s, 'WARN ')
}

pub fn (mut l PrebuiltFileLog) alert(s string) {
	if l.log_level > int(LogLevel.alert) {
		return
	}
	logx.check_daily_rotation(mut l)
	l.alert_.ch <- l.alert_.formatter(s, 'ALERT')
}

pub fn (mut l PrebuiltFileLog) error(s string) {
	if l.log_level > int(LogLevel.error) {
		return
	}
	logx.check_daily_rotation(mut l)
	l.error_.ch <- l.error_.formatter(s, 'ERROR')
}

pub fn (mut l PrebuiltFileLog) fatal(s string) {
	if l.log_level > int(LogLevel.fatal) {
		return
	}
	logx.check_daily_rotation(mut l)
	l.fatal_.ch <- l.fatal_.formatter(s, 'FATAL')
	logx.wait(mut l)
	panic(s)
}

pub fn new() !&PrebuiltFileLog {
	return logx.from_new(PrebuiltFileLog{})!
}
