BEGIN {
	FS="[,\t()]";
}
{
	if($0 ~ /^\t[ls][dwhb]\t(.*)*/ && $3 == $5) {
		print "#" $0
		print "move\t$12," $5
		print $2 "\t" $3 "," $4 "($12)"
	}
	else print
}
