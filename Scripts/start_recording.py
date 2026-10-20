#!/usr/bin/env python3
"""Launch the native recorder with a stoppable SIGINT disposition.

A noninteractive shell starts background commands with SIGINT ignored. Reset
that inherited disposition before exec; the native simctl process keeps this
same PID and receives the later graceful-stop signal. No image/video editing.
"""
import os
import signal
import sys

if len(sys.argv) != 3:
    raise SystemExit('Expected simulator ID and output MOV path')
signal.signal(signal.SIGINT, signal.SIG_DFL)
signal.signal(signal.SIGTERM, signal.SIG_DFL)
os.execvp('xcrun', ['xcrun', 'simctl', 'io', sys.argv[1], 'recordVideo', '--codec=h264', '--force', sys.argv[2]])
