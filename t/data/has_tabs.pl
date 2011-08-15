#
# This file is part of Text-VimColor
#
# This software is copyright (c) 2011 by Randy Stauner.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
# Perl script containing tabs.

if (@ARGV) {
	for (1 .. shift) {
		print "Number $_",
		      "\n";
	}
}
