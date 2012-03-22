
use strict;
use warnings;

use 5.006;

use inc::VimCommand;
use ExtUtils::MakeMaker 6.30;

use File::ShareDir::Install;
install_share dist => "share";


my %WriteMakefileArgs = (
  "ABSTRACT" => "Syntax highlight text using Vim",
  "AUTHOR" => "Geoff Richards <qef\@laxan.com>, Randy Stauner <rwstauner\@cpan.org>",
  "BUILD_REQUIRES" => {
    "Exporter" => 0,
    "File::Find" => 0,
    "Test::More" => "0.88"
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30",
    "File::ShareDir::Install" => "0.03",
    "File::Temp" => 0,
    "IO::File" => 0,
    "IPC::Open3" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "DISTNAME" => "Text-VimColor",
  "EXE_FILES" => [
    "bin/text-vimcolor"
  ],
  "LICENSE" => "perl",
  "NAME" => "Text::VimColor",
  "PREREQ_PM" => {
    "Carp" => 0,
    "File::Copy" => 0,
    "File::ShareDir" => 0,
    "File::Temp" => 0,
    "Getopt::Long" => 0,
    "IO::File" => 0,
    "Path::Class" => 0,
    "Term::ANSIColor" => "1.03",
    "strict" => 0,
    "warnings" => 0
  },
  "VERSION" => "0.17",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);

{
package
MY;
use File::ShareDir::Install qw(postamble);
}


