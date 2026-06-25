#!/usr/bin/perl
# Chantier compréhensibilité hiking (2026-06-25) — retire la citation de marque
# « Uphill Athlete » des champs AFFICHÉS uniquement (lignes >= $START = bloc "weeks").
# progression_logic / safety_notes (lignes 16-27, métadonnée coach/LLM) PRÉSERVÉS.
# Mode octets (pas de -CSD) → patterns accentués matchent littéralement.
use strict; use warnings;
my $START = 28;                 # "weeks" : [ commence ligne 28 dans les 4 fichiers
# Règles ordonnées : spécifiques (préfixe Justification/rationale, formes à virgule)
# AVANT les génériques. [old, new] littéraux.
my @rules = (
  ['Justification Uphill Athlete : ', 'Justification : '],
  ['Justificación Uphill Athlete: ',  'Justificación: '],
  ['Uphill Athlete rationale: ',      'Rationale: '],
  ['Uphill Athlete aerobic base work: ', 'Aerobic base work: '],
  [', Uphill Athlete)', ')'],
  [', Uphill Athlete.', '.'],
  [' (Uphill Athlete)', ''],
  [' Uphill Athlete)', ')'],
  [' Uphill Athlete.', '.'],
  [' Uphill Athlete : ', ' : '],
  [' Uphill Athlete: ',  ': '],
  [' Uphill Athlete =', ' ='],
);
my $file = $ARGV[0];
open(my $fh, '<', $file) or die $!;
my @lines = <$fh>; close($fh);
my $n = 0;
for my $i (0..$#lines) {
  next if ($i+1) < $START;       # 1-based line number
  for my $r (@rules) {
    my ($old,$new) = @$r;
    $n += ($lines[$i] =~ s/\Q$old\E/$new/g);
  }
}
open(my $out, '>', $file) or die $!;
print $out @lines; close($out);
print "$file: $n remplacements\n";
