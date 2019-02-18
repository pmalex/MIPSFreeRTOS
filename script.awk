BEGIN {
	FS="[,\t()]";
}
{
	if($0 ~ /^\t[ls][dwhb].*/ && $3 == $5) {
		print "#" $0
		print "move\t$12," $5
		print $2 "\t" $3 "," $4 "($12)"
	}
	else if($0 ~ /\tnop.*/){
		print $0
		print "nop"
	}
	else print
}
