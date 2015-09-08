#! /usr/bin/env perl

use strict;
use warnings;

use feature qw(say);

use Clone qw(clone);
use Data::Dumper;
use Getopt::Long;
use Tree::Binary;
use Tree::Binary::Visitor::InOrderTraversal;

{
  my $mode;

  sub handler {
    $mode = shift;
  }

  GetOptions(
      "conundrum|c" => \&handler,
      "letters|l" => \&handler,
      "numbers|n" => \&handler,
    );

  exit main($mode, @ARGV);
}

sub main {
  my $mode = shift or die "Usage: $0 --[letters|numbers] <list of letters/numbers>";

  if ($mode eq 'letters' or $mode eq 'conundrum') {
    my @letters = @_ == 1 ? split(//, shift) : @_;
    die "Need exactly 9 letters.\n" unless @letters == 9;

    my %freqMap;

    foreach (@letters) {
      $freqMap{$_}++;
    }

    my $letters = join('', keys %freqMap);

    my %words;

    open(my $fh, 'words.txt');
    outer: while(<$fh>) {
      chomp;

      next if $mode eq 'conundrum' and length($_) != 9;

      next if $_ =~ /[^$letters]/;

      foreach my $letter (keys %freqMap) {
        my $count = () = ($_ =~ /$letter/g);
        next outer if $count > $freqMap{$letter};
      }

      push(@{$words{length($_)}}, $_);
    }

    foreach (sort (keys %words)) {
      foreach my $word (@{$words{$_}}) {
        say $word;
      }
    }
  } elsif ($mode eq 'numbers') {
    die "Need exactly 6 numbers and a total" unless @_ == 7;

    my $target = pop;

    @_ = sort {$b <=> $a} @_;

    my $expressions = build_trees(
        $target,
        map {
            Tree::Binary->new({value => $_})
          } @_
      );

    if ($expressions) {
      my $visitor = Tree::Binary::Visitor::InOrderTraversal->new();
      $visitor->setNodeFilter(sub {
          my $node = shift;
          return $node->getNodeValue()->{'operator'} // $node->getNodeValue()->{'value'};
        });

      foreach (@$expressions) {
        $_->accept($visitor);
        say join(" ", $visitor->getResults())." = ".$_->getNodeValue()->{'value'};
      }
    }
  }

  return 0;
}

sub build_trees {
  my $target = shift;

  if (@_ < 2) {
    die "Empty array when expecting one element" unless @_;
    return \@_ if abs($target - $_[0]->getNodeValue()->{'value'}) <= 10;
    return;
  }

  my @trees;

  foreach my $combo (@{combinations(@_)}) {
    my $lhs = $combo->[0];
    my $rhs = $combo->[1];
    my $remainder = $combo->[2];
    my $lhsValue = $lhs->getNodeValue()->{'value'};
    my $rhsValue = $rhs->getNodeValue()->{'value'};

    if ($lhsValue == $target) {
      push @trees, $lhs;
      next;
    } elsif (abs($target - $lhsValue) <= 10) {
      push @trees, $lhs;
    }

    my $treeRef = build_trees(
        $target,
        sort byNodeValDesc (Tree::Binary->new({
            value => $lhsValue + $rhsValue,
            operator => '+'
           })->setLeft($lhs)->setRight($rhs), @{$remainder})
      );

    push @trees, @$treeRef if $treeRef;

    unless ($lhsValue == $rhsValue) {
      $treeRef = build_trees(
          $target,
          sort byNodeValDesc (Tree::Binary->new({
              value => $lhsValue - $rhsValue,
              operator => '-'
            })->setLeft($lhs)->setRight($rhs), @{$remainder})
        );

      push @trees, @$treeRef if $treeRef;
    }

    unless ($rhsValue < 2) {
      $treeRef = build_trees(
          $target,
          sort byNodeValDesc (Tree::Binary->new({
              value => $lhsValue * $rhsValue,
              operator => '*'
            })->setLeft($lhs)->setRight($rhs), @{$remainder})
        );

      push @trees, @$treeRef if $treeRef;

      unless ($lhsValue % $rhsValue) {
        $treeRef = build_trees(
            $target,
            sort byNodeValDesc (Tree::Binary->new({
                value => $lhsValue / $rhsValue,
                operator => '/'
              })->setLeft($lhs)->setRight($rhs), @{$remainder})
          );

        push @trees, @$treeRef if $treeRef;
      }
    }
  }

  return \@trees;
}

sub byNodeValDesc {
  $b->getNodeValue()->{'value'} <=> $a->getNodeValue()->{'value'}
}

sub combinations {
  my @combinations;

  for (my $i = 0; $i + 1 < @_; $i++) {
    for (my $j = $i; $j + 1 < @_; $j++) {
      my @remainder = @{clone(\@_)};
      push @combinations, [
          splice(@remainder, $i, 1),
          splice(@remainder, $j, 1),
          \@remainder
        ];
    }
  }

  return \@combinations;
}

