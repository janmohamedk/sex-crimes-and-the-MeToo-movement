clear all
set more off
pause on

cd "$DROPBOX_METOO"

*pull 2010 from 2011 files
{
* convert to dta
* JAN
import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2011-02.xls",  cellrange(A6) clear
keep A E
destring E, replace force
rename E _1
gen yearTotal = _1


keep if A == "סך הכל" |A== "עברות מין"|A== "     עברות הקשורות לזנות"
replace A = "totCrime" if A == "סך הכל"
replace A = "sexualAsst" if A == "עברות מין"
replace A = "prostitution" if A == "     עברות הקשורות לזנות"


save "data/intermediate/international_reported_crime/Israel/2010.dta", replace


clear

forval mon = 3/9{
import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2011-0`mon'.xls", cellrange(A6) clear
keep A G
destring G, replace force
local month = `mon'-1
rename G cumulative
drop if cumulative == .


keep if A == "סך הכל" |A== "עברות מין"|A== "     עברות הקשורות לזנות"

replace A = "totCrime" if A == "סך הכל"
replace A = "sexualAsst" if A == "עברות מין"
replace A = "prostitution" if A == "     עברות הקשורות לזנות"

merge 1:1 A using "data/intermediate/international_reported_crime/Israel/2010.dta"


assert _merge==3
drop _merge
gen _`month' = cumulative - yearTotal
replace yearTotal = yearTotal + _`month'
drop cumulative
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2010.dta", replace


}

forval mon = 10/11{
import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2011-`mon'.xls",  cellrange(A6) clear
keep A G
destring G, replace force
local month = `mon'-1
rename G cumulative
drop if cumulative == .

keep if A == "סך הכל" |A== "עברות מין"|A== "     עברות הקשורות לזנות"
replace A = "totCrime" if A == "סך הכל"
replace A = "sexualAsst" if A == "עברות מין"
replace A = "prostitution" if A == "     עברות הקשורות לזנות"

merge 1:1 A using "data/intermediate/international_reported_crime/Israel/2010.dta"
assert _merge==3
drop _merge
gen _`month' = cumulative - yearTotal
replace yearTotal = yearTotal + _`month'
drop cumulative
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2010.dta", replace
}

import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2011-12.xls",  cellrange(A6) clear
keep A E
destring E, replace force
rename E cumulative

keep if A == "סך הכל" |A== "עברות מין"|A== "     עברות הקשורות לזנות"
replace A = "totCrime" if A == "סך הכל"
replace A = "sexualAsst" if A == "עברות מין"
replace A = "prostitution" if A == "     עברות הקשורות לזנות"


merge 1:1 A using "data/intermediate/international_reported_crime/Israel/2010.dta"
assert _merge==3
drop _merge
gen _11 = cumulative - yearTotal
drop cumulative
replace yearTotal = yearTotal + _11
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2010.dta", replace

import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2012-01.xls",  cellrange(A6) clear
keep A E
destring E, replace force
rename E cumulative

keep if A == "סך הכל" |A== "עברות מין"|A== "     עברות הקשורות לזנות"
replace A = "totCrime" if A == "סך הכל"
replace A = "sexualAsst" if A == "עברות מין"
replace A = "prostitution" if A == "     עברות הקשורות לזנות"


merge 1:1 A using "data/intermediate/international_reported_crime/Israel/2010.dta"
assert _merge==3
drop _merge
gen _12 = cumulative - yearTotal
drop cumulative
replace yearTotal = yearTotal + _12
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2010.dta", replace


}

*pull 2011 from 2012 files
{
* convert to dta
* JAN
import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2012-02.xls",  cellrange(A6) clear
keep A E
destring E, replace force
rename E _1
gen yearTotal = _1

keep if A == "סך הכל" |A== "עברות מין"|A== "     עברות הקשורות לזנות"
replace A = "totCrime" if A == "סך הכל"
replace A = "sexualAsst" if A == "עברות מין"
replace A = "prostitution" if A == "     עברות הקשורות לזנות"
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2011.dta", replace

clear


forval mon = 3/6{
import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2012-0`mon'.xls", cellrange(A6) clear
keep A E
destring E, replace force
local month = `mon'-1
rename E cumulative
drop if cumulative == .


keep if A == "סך הכל" |A== "עברות מין"|A== "     עברות הקשורות לזנות"| A == "Sexual offences" | A == "  Offences relating to prostitution"
replace A = "totCrime" if A == "סך הכל"
replace A = "sexualAsst" if A == "עברות מין" | A == "Sexual offences"
replace A = "prostitution" if A == "     עברות הקשורות לזנות" | A == "  Offences relating to prostitution"


merge 1:1 A using "data/intermediate/international_reported_crime/Israel/2011.dta"
assert _merge==3
drop _merge
gen _`month' = cumulative - yearTotal
replace yearTotal = yearTotal + _`month'
drop cumulative
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2011.dta", replace

}

* june 2012 file in english
import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2012-07.xls",  cellrange(A6) clear
keep A E
destring E, replace force
rename E cumulative 

keep if A == "Total" |A== "Sexual offences"|A== "  Offences relating to prostitution"
replace A = "totCrime" if A == "Total"
replace A = "sexualAsst" if A == "Sexual offences"
replace A = "prostitution" if A == "  Offences relating to prostitution"

merge 1:1 A using "data/intermediate/international_reported_crime/Israel/2011.dta"
assert _merge==3
drop _merge
gen _6 = cumulative - yearTotal
replace yearTotal = yearTotal + _6
drop cumulative
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2011.dta", replace

forval mon = 8/9{
import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2012-0`mon'.xls", cellrange(A6) clear
keep A E

destring E, replace force
local month = `mon'-1
rename E cumulative
drop if cumulative == .

keep if A == "סך הכל" |A== "עברות מין"|A== "     עברות הקשורות לזנות"
replace A = "totCrime" if A == "סך הכל"
replace A = "sexualAsst" if A == "עברות מין"
replace A = "prostitution" if A == "     עברות הקשורות לזנות"

merge 1:1 A using "data/intermediate/international_reported_crime/Israel/2011.dta"
assert _merge==3
drop _merge
gen _`month' = cumulative - yearTotal
replace yearTotal = yearTotal + _`month'
drop cumulative
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2011.dta", replace
}

forval mon = 10/12{
import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2012-`mon'.xls",  cellrange(A6) clear

keep A E
destring E, replace force
local month = `mon'-1
rename E cumulative
drop if cumulative == .

keep if A == "סך הכל" |A== "עברות מין"|A== "     עברות הקשורות לזנות"
replace A = "totCrime" if A == "סך הכל"
replace A = "sexualAsst" if A == "עברות מין"
replace A = "prostitution" if A == "     עברות הקשורות לזנות"

merge 1:1 A using "data/intermediate/international_reported_crime/Israel/2011.dta"
assert _merge==3
drop _merge
gen _`month' = cumulative - yearTotal
replace yearTotal = yearTotal + _`month'
drop cumulative
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2011.dta", replace
}

import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2013-01.xls",  cellrange(A6) clear
keep A E
destring E, replace force
rename E cumulative

keep if A == "Total" |A== "Sexual offences"|A== "  Offences relating to prostitution"
replace A = "totCrime" if A == "Total"
replace A = "sexualAsst" if A == "Sexual offences"
replace A = "prostitution" if A == "  Offences relating to prostitution"

merge 1:1 A using "data/intermediate/international_reported_crime/Israel/2011.dta"
assert _merge==3
drop _merge

gen _12 = cumulative - yearTotal
drop cumulative
replace yearTotal = yearTotal + _12
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2011.dta", replace

}

*pull 2012 from 2013 files
{
import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2013-02.xls",  cellrange(A6) clear
keep A E
destring E, replace force
rename E _1
gen yearTotal = _1

drop if _1 == .

keep if A == "Total" |A== "Sexual offences"|A== "  Offences relating to prostitution"
replace A = "totCrime" if A == "Total"
replace A = "sexualAsst" if A == "Sexual offences"
replace A = "prostitution" if A == "  Offences relating to prostitution"
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2012.dta", replace

clear


forval mon = 3/9{
import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2013-0`mon'.xls",  cellrange(A6) clear
keep A E
destring E, replace force
local month = `mon'-1
rename E cumulative

keep if A == "Total" |A== "Sexual offences"|A== "  Offences relating to prostitution"
replace A = "totCrime" if A == "Total"
replace A = "sexualAsst" if A == "Sexual offences"
replace A = "prostitution" if A == "  Offences relating to prostitution"

merge 1:1 A using "data/intermediate/international_reported_crime/Israel/2012.dta"
assert _merge==3
drop _merge
gen _`month' = cumulative - yearTotal
replace yearTotal = yearTotal + _`month'
drop cumulative
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2012.dta", replace
	
}

forval mon = 10/12{
import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2013-`mon'.xls",  cellrange(A6) clear
keep A E
destring E, replace force
local month = `mon'-1
rename E cumulative

keep if A == "Total" |A== "Sexual offences"|A== "  Offences relating to prostitution"
replace A = "totCrime" if A == "Total"
replace A = "sexualAsst" if A == "Sexual offences"
replace A = "prostitution" if A == "  Offences relating to prostitution"

merge 1:1 A using "data/intermediate/international_reported_crime/Israel/2012.dta"
assert _merge==3
drop _merge
gen _`month' = cumulative - yearTotal
replace yearTotal = yearTotal + _`month'
drop cumulative
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2012.dta", replace
	
}

import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2014-01.xls",  cellrange(A6) clear
keep A E
destring E, replace force
rename E cumulative

keep if A == "Total" |A== "Sexual offences"|A== "  Offences relating to prostitution"
replace A = "totCrime" if A == "Total"
replace A = "sexualAsst" if A == "Sexual offences"
replace A = "prostitution" if A == "  Offences relating to prostitution"


merge 1:1 A using "data/intermediate/international_reported_crime/Israel/2012.dta"
assert _merge==3
drop _merge
gen _12 = cumulative - yearTotal
drop cumulative
replace yearTotal = yearTotal + _12
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2012.dta", replace

}

*pull 2013 from 2014 files
{
import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2014-02.xls",  cellrange(A6) clear
keep A E
destring E, replace force
rename E _1
gen yearTotal = _1

drop if _1 == .

keep if A == "Total" |A== "Sexual offences"|A== "  Offences relating to prostitution"
replace A = "totCrime" if A == "Total"
replace A = "sexualAsst" if A == "Sexual offences"
replace A = "prostitution" if A == "  Offences relating to prostitution"
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2013.dta", replace

clear


forval mon = 3/9{
import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2014-0`mon'.xls",  cellrange(A6) clear
keep A E
destring E, replace force
local month = `mon'-1
rename E cumulative

keep if A == "Total" |A== "Sexual offences"|A== "  Offences relating to prostitution"
replace A = "totCrime" if A == "Total"
replace A = "sexualAsst" if A == "Sexual offences"
replace A = "prostitution" if A == "  Offences relating to prostitution"

merge 1:1 A using "data/intermediate/international_reported_crime/Israel/2013.dta"
assert _merge==3
drop _merge
gen _`month' = cumulative - yearTotal
replace yearTotal = yearTotal + _`month'
drop cumulative
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2013.dta", replace
	
}

forval mon = 10/12{
import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2014-`mon'.xls",  cellrange(A6) clear
keep A E
destring E, replace force
local month = `mon'-1
rename E cumulative

keep if A == "Total" |A== "Sexual offences"|A== "  Offences relating to prostitution"
replace A = "totCrime" if A == "Total"
replace A = "sexualAsst" if A == "Sexual offences"
replace A = "prostitution" if A == "  Offences relating to prostitution"

merge 1:1 A using "data/intermediate/international_reported_crime/Israel/2013.dta"
assert _merge==3
drop _merge
gen _`month' = cumulative - yearTotal
replace yearTotal = yearTotal + _`month'
drop cumulative
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2013.dta", replace
	
}

import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2015-01.xls",  cellrange(A6) clear
keep A E
destring E, replace force
rename E cumulative

keep if A == "Total" |A== "Sexual offences"|A== "  Offences relating to prostitution"
replace A = "totCrime" if A == "Total"
replace A = "sexualAsst" if A == "Sexual offences"
replace A = "prostitution" if A == "  Offences relating to prostitution"


merge 1:1 A using "data/intermediate/international_reported_crime/Israel/2013.dta"
assert _merge==3
drop _merge
gen _12 = cumulative - yearTotal
drop cumulative
replace yearTotal = yearTotal + _12
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2013.dta", replace
}

*pull 2014 from 2014 (no 2015 files)
{
import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2014-02.xls",  cellrange(A6) clear
keep A C
destring C, replace force
rename C _1
gen yearTotal = _1

drop if _1 == .

keep if A == "Total" |A== "Sexual offences"|A== "  Offences relating to prostitution"
replace A = "totCrime" if A == "Total"
replace A = "sexualAsst" if A == "Sexual offences"
replace A = "prostitution" if A == "  Offences relating to prostitution"
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2014.dta", replace

clear


forval mon = 3/9{
import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2014-0`mon'.xls",  cellrange(A6) clear
keep A C
destring C, replace force
local month = `mon'-1
rename C cumulative

keep if A == "Total" |A== "Sexual offences"|A== "  Offences relating to prostitution"
replace A = "totCrime" if A == "Total"
replace A = "sexualAsst" if A == "Sexual offences"
replace A = "prostitution" if A == "  Offences relating to prostitution"

merge 1:1 A using "data/intermediate/international_reported_crime/Israel/2014.dta"
assert _merge==3
drop _merge
gen _`month' = cumulative - yearTotal
replace yearTotal = yearTotal + _`month'
drop cumulative
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2014.dta", replace
	
}

forval mon = 10/12{
import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2014-`mon'.xls",  cellrange(A6) clear
keep A C
destring C, replace force
local month = `mon'-1
rename C cumulative

keep if A == "Total" |A== "Sexual offences"|A== "  Offences relating to prostitution"
replace A = "totCrime" if A == "Total"
replace A = "sexualAsst" if A == "Sexual offences"
replace A = "prostitution" if A == "  Offences relating to prostitution"

merge 1:1 A using "data/intermediate/international_reported_crime/Israel/2014.dta"
assert _merge==3
drop _merge
gen _`month' = cumulative - yearTotal
replace yearTotal = yearTotal + _`month'
drop cumulative
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2014.dta", replace
	
}

import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2015-01.xls",  cellrange(A6) clear
keep A C
destring C, replace force
rename C cumulative

keep if A == "Total" |A== "Sexual offences"|A== "  Offences relating to prostitution"
replace A = "totCrime" if A == "Total"
replace A = "sexualAsst" if A == "Sexual offences"
replace A = "prostitution" if A == "  Offences relating to prostitution"


merge 1:1 A using "data/intermediate/international_reported_crime/Israel/2014.dta"
assert _merge==3
drop _merge
gen _12 = cumulative - yearTotal
drop cumulative
replace yearTotal = yearTotal + _12
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2014.dta", replace
}

*pull 2015 from 2016 files
{
import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2016-02.xls",  cellrange(A6) clear
keep A E
destring E, replace force
rename E _1
gen yearTotal = _1

drop if _1 == .
gen N = _n

keep if N == 1| N == 33 | N == 40

replace A = subinstr(A, " ", "", .)

replace A = "totCrime" if A == "GrandTotal"
replace A = "sexAsst" if A == "Totaloffences"
replace A = "prostitution" if A == "Offencesrelatingtoprostitution"
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2015.dta", replace


forval mon = 3/9{
import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2016-0`mon'.xls",  cellrange(A6) clear
keep A E
destring E, replace force
local month = `mon'-1
rename E cumulative
drop if cumulative == .

gen N = _n
keep if N == 1| N == 33 | N == 40

replace A = subinstr(A, " ", "", .)

replace A = "totCrime" if A == "GrandTotal"
replace A = "sexAsst" if A == "Totaloffences"
replace A = "prostitution" if A == "Offencesrelatingtoprostitution"

merge 1:1 A using "data/intermediate/international_reported_crime/Israel/2015.dta"
assert _merge==3
drop _merge
gen _`month' = cumulative - yearTotal
replace yearTotal = yearTotal + _`month'
drop cumulative
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2015.dta", replace
	
}

forval mon = 10/12{
import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2016-`mon'.xls",  cellrange(A6) clear
keep A E
destring E, replace force
local month = `mon'-1
rename E cumulative
drop if cumulative == .

gen N = _n
keep if N == 1| N == 33 | N == 40

replace A = subinstr(A, " ", "", .)

replace A = "totCrime" if A == "GrandTotal"
replace A = "sexAsst" if A == "Totaloffences"
replace A = "prostitution" if A == "Offencesrelatingtoprostitution"


merge 1:1 A using "data/intermediate/international_reported_crime/Israel/2015.dta"
assert _merge==3
drop _merge
gen _`month' = cumulative - yearTotal
replace yearTotal = yearTotal + _`month'
drop cumulative
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2015.dta", replace
	
}

import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2017-01.xls",  cellrange(A6) clear
keep A E
destring E, replace force
rename E cumulative
drop if cumulative == .

gen N = _n
keep if N == 1| N == 33 | N == 40

replace A = subinstr(A, " ", "", .)

replace A = "totCrime" if A == "GrandTotal"
replace A = "sexAsst" if A == "Totaloffences"
replace A = "prostitution" if A == "Offencesrelatingtoprostitution"



merge 1:1 A using "data/intermediate/international_reported_crime/Israel/2015.dta"
assert _merge==3
drop _merge
gen _12 = cumulative - yearTotal
drop cumulative
replace yearTotal = yearTotal + _12
drop N
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2015.dta", replace
}

*pull 2016 from 2017 files
{
import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2017-02.xls",  cellrange(A6) clear
keep A E
destring E, replace force
rename E _1
gen yearTotal = _1

drop if _1 == .
gen N = _n

keep if N == 1| N == 33 | N == 40

replace A = subinstr(A, " ", "", .)
replace A = "totCrime" if A == "GrandTotal"
replace A = "sexAsst" if A == "Totaloffences"
replace A = "prostitution" if A == "Offencesrelatingtoprostitution"
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2016.dta", replace


forval mon = 3/9{
import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2017-0`mon'.xls",  cellrange(A6) clear
keep A E
destring E, replace force
local month = `mon'-1
rename E cumulative
drop if cumulative == .

gen N = _n
keep if N == 1| N == 33 | N == 40

replace A = subinstr(A, " ", "", .)
replace A = "totCrime" if A == "GrandTotal"
replace A = "sexAsst" if A == "Totaloffences"
replace A = "prostitution" if A == "Offencesrelatingtoprostitution"

merge 1:1 A using "data/intermediate/international_reported_crime/Israel/2016.dta"
assert _merge==3
drop _merge
gen _`month' = cumulative - yearTotal
replace yearTotal = yearTotal + _`month'
drop cumulative
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2016.dta", replace
	
}

forval mon = 10/12{
import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2017-`mon'.xls",  cellrange(A6) clear
keep A E
destring E, replace force
local month = `mon'-1
rename E cumulative
drop if cumulative == .

gen N = _n
keep if N == 1| N == 33 | N == 40

replace A = subinstr(A, " ", "", .)
replace A = "totCrime" if A == "GrandTotal"
replace A = "sexAsst" if A == "Totaloffences"
replace A = "prostitution" if A == "Offencesrelatingtoprostitution"


merge 1:1 A using "data/intermediate/international_reported_crime/Israel/2016.dta"
assert _merge==3
drop _merge
gen _`month' = cumulative - yearTotal
replace yearTotal = yearTotal + _`month'
drop cumulative
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2016.dta", replace
	
}

import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2018-01.xls",  cellrange(A6) clear
keep A E
destring E, replace force
rename E cumulative
drop if cumulative == .

gen N = _n
keep if N == 1| N == 33 | N == 40

replace A = subinstr(A, " ", "", .)
replace A = "totCrime" if A == "GrandTotal"
replace A = "sexAsst" if A == "Totaloffences"
replace A = "prostitution" if A == "Offencesrelatingtoprostitution"

merge 1:1 A using "data/intermediate/international_reported_crime/Israel/2016.dta"
assert _merge==3
drop _merge
gen _12 = cumulative - yearTotal
drop cumulative
replace yearTotal = yearTotal + _12
drop N
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2016.dta", replace
}

*pull 2017 from 2018 files
{
import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2018-02.xls",  cellrange(A6) clear
keep A E
destring E, replace force
rename E _1
gen yearTotal = _1

drop if _1 == .
gen N = _n

keep if N == 1| N == 33 | N == 40

replace A = subinstr(A, " ", "", .)
replace A = "totCrime" if A == "GrandTotal"
replace A = "sexAsst" if A == "Totaloffences"
replace A = "prostitution" if A == "Offencesrelatingtoprostitution"

sleep 1000
save "data/intermediate/international_reported_crime/Israel/2017.dta", replace


forval mon = 3/9{
import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2018-0`mon'.xls",  cellrange(A6) clear
keep A E
destring E, replace force
local month = `mon'-1
rename E cumulative
drop if cumulative == .

gen N = _n
keep if N == 1| N == 33 | N == 40

replace A = subinstr(A, " ", "", .)
replace A = "totCrime" if A == "GrandTotal"
replace A = "sexAsst" if A == "Totaloffences"
replace A = "prostitution" if A == "Offencesrelatingtoprostitution"

merge 1:1 A using "data/intermediate/international_reported_crime/Israel/2017.dta"
assert _merge==3
drop _merge
gen _`month' = cumulative - yearTotal
replace yearTotal = yearTotal + _`month'
drop cumulative N
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2017.dta", replace
}

forval mon = 10/11{
import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2018-`mon'.xls",  cellrange(A6) clear
keep A E
destring E, replace force
local month = `mon'-1
rename E cumulative
drop if cumulative == .

gen N = _n
keep if N == 1| N == 33 | N == 40

replace A = subinstr(A, " ", "", .)
replace A = "totCrime" if A == "GrandTotal"
replace A = "sexAsst" if A == "Totaloffences"
replace A = "prostitution" if A == "Offencesrelatingtoprostitution"

merge 1:1 A using "data/intermediate/international_reported_crime/Israel/2017.dta"
assert _merge==3
drop _merge
gen _`month' = cumulative - yearTotal
replace yearTotal = yearTotal + _`month'
drop cumulative N
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2017.dta", replace
}

import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2018-12.xls",  cellrange(A6) clear
keep A E
destring E, replace force
rename E cumulative
drop if cumulative == .

gen N = _n

keep if N == 1| N == 33 | N == 39

replace A = subinstr(A, " ", "", .)
replace A = "totCrime" if A == "GrandTotal"
replace A = "sexAsst" if A == "Totaloffences"
replace A = "prostitution" if A == "Offencesrelatingtoprostitution"


merge 1:1 A using "data/intermediate/international_reported_crime/Israel/2017.dta"
*assert _merge==3
drop _merge
gen _11 = cumulative - yearTotal
replace yearTotal = yearTotal + _11
drop cumulative N
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2017.dta", replace


import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2019-01.xls",  cellrange(A6) clear
keep A E
destring E, replace force
rename E cumulative
drop if cumulative == .

gen N = _n
keep if N == 1| N == 33 | N == 39

replace A = subinstr(A, " ", "", .)
replace A = "totCrime" if A == "GrandTotal"
replace A = "sexAsst" if A == "Totaloffences"
replace A = "prostitution" if A == "Offencesrelatingtoprostitution"



merge 1:1 A using "data/intermediate/international_reported_crime/Israel/2017.dta"
assert _merge==3
drop _merge
gen _12 = cumulative - yearTotal
drop cumulative N
replace yearTotal = yearTotal + _12
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2017.dta", replace
}

*pull 2018 from 2019 files
{
import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2019-02.xls",  cellrange(A6) clear
keep A E
destring E, replace force
rename E _1
gen yearTotal = _1

drop if _1 == .
gen N = _n

keep if N == 1| N == 33 | N == 39

replace A = subinstr(A, " ", "", .)
replace A = "totCrime" if A == "GrandTotal"
replace A = "sexAsst" if A == "Totaloffences"
replace A = "prostitution" if A == "Offencesrelatingtoprostitution"

drop N
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2018.dta", replace


forval mon = 3/9{
import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2019-0`mon'.xls",  cellrange(A6) clear
keep A E
destring E, replace force
local month = `mon'-1
rename E cumulative
drop if cumulative == .

gen N = _n
keep if N == 1| N == 33 | N == 39

replace A = subinstr(A, " ", "", .)
replace A = "totCrime" if A == "GrandTotal"
replace A = "sexAsst" if A == "Totaloffences"
replace A = "prostitution" if A == "Offencesrelatingtoprostitution"

merge 1:1 A using "data/intermediate/international_reported_crime/Israel/2018.dta"
assert _merge==3
drop _merge
gen _`month' = cumulative - yearTotal
replace yearTotal = yearTotal + _`month'
drop cumulative N
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2018.dta", replace
}

forval mon = 10/11{
import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2019-`mon'.xls",  cellrange(A6) clear
keep A E
destring E, replace force
local month = `mon'-1
rename E cumulative
drop if cumulative == .

gen N = _n
keep if N == 1| N == 33 | N == 39

replace A = subinstr(A, " ", "", .)
replace A = "totCrime" if A == "GrandTotal"
replace A = "sexAsst" if A == "Totaloffences"
replace A = "prostitution" if A == "Offencesrelatingtoprostitution"

merge 1:1 A using "data/intermediate/international_reported_crime/Israel/2018.dta"
assert _merge==3
drop _merge
gen _`month' = cumulative - yearTotal
replace yearTotal = yearTotal + _`month'
drop cumulative N
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2018.dta", replace
}

import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2019-12.xls",  cellrange(A6) clear
keep A E
destring E, replace force
rename E cumulative
drop if cumulative == .

gen N = _n

keep if N == 1| N == 33 | N == 40

replace A = subinstr(A, " ", "", .)
replace A = "totCrime" if A == "GrandTotal"
replace A = "sexAsst" if A == "Totaloffences"
replace A = "prostitution" if A == "Offencesrelatingtoprostitution"


merge 1:1 A using "data/intermediate/international_reported_crime/Israel/2018.dta"
*assert _merge==3
drop _merge
gen _11 = cumulative - yearTotal
replace yearTotal = yearTotal + _11
drop cumulative N
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2018.dta", replace


import excel using "data/raw/international_reported_crime/Israel/Monthly data/Raw/2020-01.xls",  cellrange(A6) clear
keep A E
destring E, replace force
rename E cumulative
drop if cumulative == .

gen N = _n
keep if N == 1| N == 33 | N == 40

replace A = subinstr(A, " ", "", .)
replace A = "totCrime" if A == "GrandTotal"
replace A = "sexAsst" if A == "Totaloffences"
replace A = "prostitution" if A == "Offencesrelatingtoprostitution"



merge 1:1 A using "data/intermediate/international_reported_crime/Israel/2018.dta"
assert _merge==3
drop _merge
gen _12 = cumulative - yearTotal
drop cumulative N
replace yearTotal = yearTotal + _12
sleep 1000
save "data/intermediate/international_reported_crime/Israel/2018.dta", replace
}

* Merge data
use "data/intermediate/international_reported_crime/Israel/2018.dta", clear
drop yearTotal
xpose, clear varname
drop if v1 == .
rename v1 exclude 
rename v2 sex_assault
rename v3 all_crime
gen month = _n
gen year = 2018
drop _varname
sleep 1000
save "data/intermediate/international_reported_crime/Israel/israelCrime_temp.dta", replace

forval year = 0/7 {
use "data/intermediate/international_reported_crime/Israel/201`year'.dta", clear
drop yearTotal
xpose, clear varname
drop if v1 == .
rename v1 exclude 
rename v2 sex_assault
rename v3 all_crime
gen month = _n
gen year = `year'+2010
drop _varname

append using "data/intermediate/international_reported_crime/Israel/israelCrime_temp.dta"
sleep 1000
save "data/intermediate/international_reported_crime/Israel/israelCrime_temp.dta", replace
}


* Create counts for all crimes exclusing metoo 
gen all_crime_exc_me_too = all_crime - exclude 

sort year month
*check trends
gen time = _n
line all_crime_exc_me_too time , xline(94)
sleep 1000

line sex_assault time , xline(94)
sleep 1000

drop time


gen country_code = "IL"
drop exclude
sleep 1000
save "data/intermediate/international_reported_crime/Israel/israelCrime.dta", replace
