#!/usr/bin/env lua53

require 'stringx'

local print = print

local buf_read = require 'buffer'.read

local function check_ok(ok, msg, ...)
	if ok then
		return msg, ...
	else
		return '[error] ', msg, debug.traceback()
	end
end

local function buf_read_ok(buf, ins)
	return check_ok(pcall(buf_read, buf, ins))
end

local function check_failed(ok, msg, ...)
	if ok then
		return msg, ...
	else
		return 'expected error : ', msg, ...
	end
end

local function buf_read_error(buf, ins)
	return check_failed(pcall(buf_read, buf, ins))
end

local buf = ('030000006c7561'):from_hex()
print(buf_read(buf, 's4'))

-- move pointer
print(buf_read_ok(buf, '+7'))
print(buf_read_ok(buf, '+2 +5 -7'))
print(buf_read_error(buf, '+2 +5 -8'))

-- read boolean value
buf = ('0100'):from_hex()
print(buf_read_ok(buf, 'b'))
print(buf_read_ok(buf, 'b1'))
print(buf_read_ok(buf, 'b1 b1'))
print(buf_read_ok(buf, '*2 b1'))
print(buf_read_ok(buf, 'b2'))
print(buf_read_error(buf, '*3 b1'))
print(buf_read_error(buf, 'b1 b1 b1'))

-- read integer
buf = ('0102'):from_hex()
print(buf_read_ok(buf, 'i1'))
print(0x0201, buf_read_ok(buf, '< i2'))
print(0x0102, buf_read_ok(buf, '> i2'))

print(buf_read_ok(buf, '+1 i1'))

buf = ('0100FF0100'):from_hex()
print('should be two 1: ', buf_read_ok(buf, '&i2 +$1 i2'))

buf = ('0102 FF01 000F'):from_hex()
print(buf_read_ok(buf, '*2 &i1 +$1 +$1 i1'))
print(buf_read_ok(buf, '*2 &i1 +$1 +$2 i1'))
print(buf_read_ok(buf, '*6 &i1'))
print(buf_read_ok(buf, '$i1 +$1 *4 i1'))
print(buf_read_error(buf, '*7 i1'))
print(buf_read_error(buf, '$i1 +$1 *5 i1'))

-- abc
buf = ('61 62 63 00'):from_hex()
print(buf_read_ok(buf, 's'))
buf = ('61 62 63'):from_hex()
print(buf_read_error(buf, 's'))
print(buf_read_ok(buf, 'c1'))
print(buf_read_ok(buf, 'c3'))
print(buf_read_error(buf, 'c4'))

buf = ('03 61 62 63'):from_hex()
print(buf_read_ok(buf, 's1'))

buf = ('03 00 61 62 63'):from_hex()
print(buf_read_ok(buf, '< s2'))

buf = ('03 00 61 62 63'):from_hex()
print(buf_read_error(buf, '> s2'))

buf = ('00 03 61 62 63'):from_hex()
print(buf_read_ok(buf, '> s2'))


