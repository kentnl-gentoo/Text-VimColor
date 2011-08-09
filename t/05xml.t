# Check that the XML output is correct.
# Also checks that tabs aren't tampered with.

use strict;
use warnings;
use Test::More;
use Text::VimColor;
require "t/lib/test_env.pm";
use IO::File;

my $NS = 'http://ns.laxan.com/text-vimcolor/1';
my %SYNTYPES = map { $_ => 1 } qw(
   Comment Constant Identifier Statement Preproc
   Type Special Underlined Error Todo
);

my @EXPECTED_PERL_SYN = qw(
   Comment
   Statement Identifier
   Statement Constant Statement
   Statement Constant Identifier Constant
   Constant Special Constant
);
my @EXPECTED_NOFT_SYN = qw(
   Comment
   Constant
   Constant
);

eval " use XML::Parser ";
if ($@) {
   plan skip_all => 'XML::Parser module required for these tests.';
   exit 0;
}
else {
   plan tests => 12;
}

# Syntax color a Perl program, and check the XML output for well-formedness
# and validity.  The tests are run with and without a root element in the
# output, and with both filename and string as input.
my $filename = 't/has_tabs.pl';
my $file = IO::File->new($filename, 'r')
   or die "error opening file '$filename': $!";
my $data = do { local $/; <$file> };
my $syntax = Text::VimColor->new(
   file => $filename,
);
my $syntax_noroot = Text::VimColor->new(
   file => $filename, xml_root_element => 0,
);
my $syntax_str = Text::VimColor->new(
   string => $data,
);
my $syntax_str_noroot = Text::VimColor->new(
   string => $data, xml_root_element => 0,
);

my %syntax = (
   'no root element, filename input' => $syntax_noroot,
   'no root element, string input' => $syntax_str_noroot,
   'root element, filename input' => $syntax,
   'root element, string input' => $syntax_str,
);

# These are filled in by the handler subs below.
my $text;
my $root_elem_count;
my $inside_element;
my @syntax_types;

my $parser = XML::Parser->new(
   Handlers => {
      Start => \&handle_start,
      End => \&handle_end,
      Char => \&handle_text,
      Default => \&handle_default,
   },
);

foreach my $test_type (sort keys %syntax) {
   #diag("Doing XML tests for configuration '$test_type'.");
   my $syn = $syntax{$test_type};
   my $xml = $syn->xml;

   # The ones without root elements need to be faked.
   if ($test_type =~ /no root/) {
      $xml = "<syn:syntax xmlns:syn='$NS'>$xml</syn:syntax>";
   }

   # Reset globals.
   $text = '';
   $root_elem_count = 0;
   $inside_element = 0;
   @syntax_types = ();

   $parser->parse($xml);

   is($text, $data,
      "check that text from XML output matches original");
   is($root_elem_count, 1,
      "there should only be one root element");

   if ($test_type =~ /string/) {
      # Only expected to find string literals and comments.
      is_deeply(\@EXPECTED_NOFT_SYN, \@syntax_types,
                "check that the syntax types marked come in the right order");
   }
   else {
      is_deeply(\@EXPECTED_PERL_SYN, \@syntax_types,
                "check that the syntax types marked come in the right order");
   }
}


sub handle_text
{
   my ($expat, $s) = @_;
   $text .= $s;
}

sub handle_start
{
   my ($expat, $element, %attr) = @_;
   $element =~ /^syn:(.*)\z/
      or fail("element <$element> has wrong prefix"), return;
   $element = $1;

   fail("element <syn:$element> shouldn't be nested in something")
      if $inside_element;

   if ($element eq 'syntax') {
      ++$root_elem_count;
      fail("namespace declaration missing from root element")
         unless $attr{'xmlns:syn'};
      fail("wrong namespace declaration in root element")
         unless $attr{'xmlns:syn'} eq $NS;
   }
   else {
      $inside_element = 1;
      fail("bad element <syn:$element>")
         if !$SYNTYPES{$element};
      fail("element <syn:$element> shouldn't have any attributes")
         if keys %attr;

      push @syntax_types, $element;
   }
}

sub handle_end
{
   my ($expat, $element) = @_;
   $element =~ /^syn:(.*)\z/
      or fail("element <$element> has wrong prefix"), return;
   $element = $1;

   $inside_element = 0;

   if ($element ne 'syntax' && !$SYNTYPES{$element}) {
      fail("bad element <syn:$element>");
      return;
   }
}

sub handle_default
{
   my ($expat, $s) = @_;
   return unless $s =~ /\S/;
   die "unexpected XML event for text '$s'\n";
}

# vim:ft=perl ts=3 sw=3 expandtab:
