#!/usr/bin/env perl

use strict;
use warnings;

use Text::CSV_XS;
use JSON;

my $fields = [];
open my $io, '<:encoding(cp932)', 'data.csv';
my $csv = Text::CSV_XS->new({ sep_char  => ",", binary => 1, auto_diag => 2, quote_char => '"', eol => "\n" });

$csv->getline($io); # ダウンロードした時刻
$csv->getline($io); # 空行
$csv->getline($io); # 地点
$csv->getline($io); # カラム情報
$csv->getline($io); # 分類

my $stats = {};

$csv->column_names(qw/date amount/);
while (my $row = $csv->getline_hr($io)) {
	my $date = sprintf('%02d-%02d', (split(qr{/}, $row->{date}))[1, -1]);
	my $amount = $row->{amount};

	$stats->{$date}->{total}++;
	if ($amount > 0) {
		$stats->{$date}->{rain}++;
	}
}
close $io;

for my $date (keys $stats) {
	$stats->{$date} = $stats->{$date}->{rain} / $stats->{$date}->{total} * 1;
}

print encode_json($stats);

__END__
http://www.data.jma.go.jp/gmd/risk/obsdl/index.php#
から
- 東京
- 日別
- 降水量の日合計
- 降雪量日合計

