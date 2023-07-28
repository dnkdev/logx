module logx

import os
import time

pub type FormatterFunc = fn (string, string) string

[inline]
pub fn default_formatter(s string, tag string) string {
	timestamp := time.now().format_ss_milli()
	return '${timestamp} [${tag}] ${s}'
}

pub struct LevelInfo{
pub mut:
	formatter	FormatterFunc = default_formatter
	ofile		os.File
	ch			chan string
	file_path	string
	max_size	u64
	priority 	int
	name 		string
}
