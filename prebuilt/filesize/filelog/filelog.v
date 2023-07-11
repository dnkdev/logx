module filelog

import logx

[rotation: 'filesize']
pub struct PrebuiltFileLog {
pub mut:
	trace_    logx.LevelInfo [max_size: '1MB'; cap: 10000; file: 'logs/trace/trace.log']
	debug_    logx.LevelInfo [max_size: '1MB'; cap: 9000; file: 'logs/debug/debug.log']
	info_     logx.LevelInfo [max_size: '1MB'; cap: 8000; file: 'logs/info/info.log']
	note_     logx.LevelInfo [max_size: '1MB'; cap: 7000; file: 'logs/note/note.log']
	warn_     logx.LevelInfo [max_size: '1MB'; cap: 1000; file: 'logs/warn/warn.log']
	alert_    logx.LevelInfo [max_size: '1MB'; cap: 1000; file: 'logs/alert/alert.log']
	error_    logx.LevelInfo [max_size: '1MB'; cap: 1000; file: 'logs/error/error.log']
	fatal_    logx.LevelInfo [max_size: '1MB'; cap: 1; file: 'logs/fatal/fatal.log']
	log_level int
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
	logx.check_level_size_rotation(mut l.trace_)
	l.trace_.ch <- l.trace_.formatter(s, 'TRACE')
}

pub fn (mut l PrebuiltFileLog) debug(s string) {
	if l.log_level > int(LogLevel.debug) {
		return
	}
	logx.check_level_size_rotation(mut l.debug_)
	l.debug_.ch <- l.debug_.formatter(s, 'DEBUG')
}

pub fn (mut l PrebuiltFileLog) info(s string) {
	if l.log_level > int(LogLevel.info) {
		return
	}
	logx.check_level_size_rotation(mut l.info_)
	l.info_.ch <- l.info_.formatter(s, 'INFO ')
}

pub fn (mut l PrebuiltFileLog) note(s string) {
	if l.log_level > int(LogLevel.note) {
		return
	}
	logx.check_level_size_rotation(mut l.note_)
	l.note_.ch <- l.note_.formatter(s, 'NOTE ')
}

pub fn (mut l PrebuiltFileLog) warn(s string) {
	if l.log_level > int(LogLevel.warn) {
		return
	}
	logx.check_level_size_rotation(mut l.warn_)
	l.warn_.ch <- l.warn_.formatter(s, 'WARN ')
}

pub fn (mut l PrebuiltFileLog) alert(s string) {
	if l.log_level > int(LogLevel.alert) {
		return
	}
	logx.check_level_size_rotation(mut l.alert_)
	l.alert_.ch <- l.alert_.formatter(s, 'ALERT')
}

pub fn (mut l PrebuiltFileLog) error(s string) {
	if l.log_level > int(LogLevel.error) {
		return
	}
	logx.check_level_size_rotation(mut l.error_)
	l.error_.ch <- l.error_.formatter(s, 'ERROR')
}

pub fn (mut l PrebuiltFileLog) fatal(s string) {
	if l.log_level > int(LogLevel.fatal) {
		return
	}
	logx.check_level_size_rotation(mut l.fatal_)
	l.fatal_.ch <- l.fatal_.formatter(s, 'FATAL')
	logx.wait(mut l)
	panic(s)
}

pub fn new() !&PrebuiltFileLog {
	return logx.from_new(PrebuiltFileLog{})!
}
