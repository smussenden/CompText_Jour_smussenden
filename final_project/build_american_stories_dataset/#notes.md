# notes.md

## Intro. Methodology exploration 
## Talk about research paper
--What it found
--Built off of project we did called printing hate

## Talk about dataset we used Chron Am
--Good things: a ton of newspapers in it; LONG historical coverage; API access and raw image access to work with computational access; Broad geographic coverage; FREE and accessible (good luck using newspapers.com); A good amount of scholarship using it as a computational source
--Bad things: spotty OCR quality; page level text, not article level text; coverage may be long and geographically broad, but huge gaps both temporally and geographically; article layout is complex (modern newspapers have a familiar rhythm); Huge newspaper type gaps too (not a lot of black newspapers), but you do get like russian language or german papers randomly; Just stops at certain point because of copyright issues. 

## Overcomign those issues -- getting to article level data 
--- Article level = hard, because of old newspaper layout. 
--- Let's look at modern NYT example. This is fairly easy, and a lot of good tools for this
--- Let's look at old example. Random jumps. 
--- When we started this research, there were some tools to extract article level stuff from historic papers. But not great.  And state of art OCR was much better than it was, but still not ... awesome. 
--- Required a mix of comptuational and manual processes to extract articles, which was also hard. 
--- First had to identify potential lynching articles, because couldn't review every single page! that's hard because of misspellings.  JUST LUCK AT THIS FUCKING REGEX. 
--- And then had to go in and manually extract them at the article level. Built a custom tool to do that (Article Extractor). This took a ton of bodies! 
--- And then we had to go in and classify themes to answer key questions. 

## Oh, so you're telling me there's a better way
--- American Stories.  
--- LLM classification

## 



Built tool to do X. 
--- Because of that, limited scale; can't manually extract every article
--- Used regex to filter dataset, which was insane, because of spelling and other issue (Look at this insane regex)

--Talk about problems with chron am
Step 1. Download American Stories (Download American Stories Data.Py)

Step 2. 


Jakc regex "lynchings?\W+of\W+(the\W+)?((\w+\W+){1,2})?colored" "(murderer\|fiend\|desperado\|brute)\W+((\w+\W+){1,2})?lynch(ed\|es\|ing)?(\W+\|$)"    "coloreds?\W+((\w+\W+){1,2})?((was|were)\W+)?lynch(ed|es|ing)?(\W+|$)" "lynchings?\W+of\W+(the\W+)?((\w+\W+){1,2})?negro" "mob\W+((\w+\W+){1,2})?(hung\|hang(ed\|ings?\|s)\|lynch(ed\|es\|ing)?)" "negro(e?s)?\W+((\w+\W+){1,2})?((was\|were)\W+)?lynch(ed\|es\|ing)?(\W+\|$)"    "lynchings?\W+of\W+(the\W+)?((\w+\W+){1,2})?colored"_num_matches    "(murderer|fiend|desperado|brute)\W+((\w+\W+){1,2})?lynch(ed|es|ing)?(\W+|$)"\_num_matches "coloreds?\W+((\w+\W+){1,2})?((was\|were)\W+)?lynch(ed\|es\|ing)?(\W+\|$)"_num_matches    "lynchings?\W+of\W+(the\W+)?((\w+\W+){1,2})?negro"_num_matches    "mob\W+((\w+\W+){1,2})?(hung|hang(ed|ings?|s)|lynch(ed|es|ing)?)"_num_matches    "negro(e?s)?\W+((\w+\W+){1,2})?((was|were)\W+)?lynch(ed|es|ing)?(\W+|$)"\_num_matches Unnamed: 0 "lynchings?\W+of\W+(the\W+)?((\w+\W+){1,2})?colored"\_start_idx "lynchings?\W+of\W+(the\W+)?((\w+\W+){1,2})?colored"\_end_idx "lynchings?\W+of\W+(the\W+)?((\w+\W+){1,2})?colored"\_cost "lynchings?\W+of\W+(the\W+)?((\w+\W+){1,2})?colored"\_SEARCH_cost_threshold "coloreds?\W+((\w+\W+){1,2})?((was\|were)\W+)?lynch(ed\|es\|ing)?(\W+\|$)"_start_idx    "coloreds?\W+((\w+\W+){1,2})?((was|were)\W+)?lynch(ed|es|ing)?(\W+|$)"\_end_idx "coloreds?\W+((\w+\W+){1,2})?((was\|were)\W+)?lynch(ed\|es\|ing)?(\W+\|$)"_cost    "coloreds?\W+((\w+\W+){1,2})?((was|were)\W+)?lynch(ed|es|ing)?(\W+|$)"\_SEARCH_cost_threshold "lynchings?\W+of\W+(the\W+)?((\w+\W+){1,2})?negro"\_start_idx "lynchings?\W+of\W+(the\W+)?((\w+\W+){1,2})?negro"\_end_idx "lynchings?\W+of\W+(the\W+)?((\w+\W+){1,2})?negro"\_cost "lynchings?\W+of\W+(the\W+)?((\w+\W+){1,2})?negro"\_SEARCH_cost_threshold "negro(e?s)?\W+((\w+\W+){1,2})?((was\|were)\W+)?lynch(ed\|es\|ing)?(\W+\|$)"_start_idx    "negro(e?s)?\W+((\w+\W+){1,2})?((was|were)\W+)?lynch(ed|es|ing)?(\W+|$)"\_end_idx "negro(e?s)?\W+((\w+\W+){1,2})?((was\|were)\W+)?lynch(ed\|es\|ing)?(\W+\|$)"_cost    "negro(e?s)?\W+((\w+\W+){1,2})?((was|were)\W+)?lynch(ed|es|ing)?(\W+|$)"\_SEARCH_cost_threshold "mob\W+((\w+\W+){1,2})?(hung\|hang(ed\|ings?\|s)\|lynch(ed\|es\|ing)?)"\_start_idx "mob\W+((\w+\W+){1,2})?(hung\|hang(ed\|ings?\|s)\|lynch(ed\|es\|ing)?)"\_end_idx "mob\W+((\w+\W+){1,2})?(hung\|hang(ed\|ings?\|s)\|lynch(ed\|es\|ing)?)"\_cost "(murderer\|fiend\|desperado\|brute)\W+((\w+\W+){1,2})?lynch(ed\|es\|ing)?(\W+\|$)"_start_idx    "(murderer|fiend|desperado|brute)\W+((\w+\W+){1,2})?lynch(ed|es|ing)?(\W+|$)"\_end_idx "(murderer\|fiend\|desperado\|brute)\W+((\w+\W+){1,2})?lynch(ed\|es\|ing)?(\W+\|$)"_cost    "mob\W+((\w+\W+){1,2})?(hung|hang(ed|ings?|s)|lynch(ed|es|ing)?)"_SEARCH_cost_threshold    "(murderer|fiend|desperado|brute)\W+((\w+\W+){1,2})?lynch(ed|es|ing)?(\W+|$)"\_SEARCH_cost_threshold batch "lynchings?\W+of\W+(the\W+)?((\w+\W+){1,2})?colored"\_CLEANING_cost_threshold "coloreds?\W+((\w+\W+){1,2})?((was\|were)\W+)?lynch(ed\|es\|ing)?(\W+\|$)"_CLEANING_cost_threshold    "lynchings?\W+of\W+(the\W+)?((\w+\W+){1,2})?negro"_CLEANING_cost_threshold    "negro(e?s)?\W+((\w+\W+){1,2})?((was|were)\W+)?lynch(ed|es|ing)?(\W+|$)"\_CLEANING_cost_threshold "mob\W+((\w+\W+){1,2})?(hung\|hang(ed\|ings?\|s)\|lynch(ed\|es\|ing)?)"\_CLEANING_cost_threshold "(murderer\|fiend\|desperado\|brute)\W+((\w+\W+){1,2})?lynch(ed\|es\|ing)?(\W+\|$)"_CLEANING_cost_threshold    "lynchings?\W+of\W+(the\W+)?((\w+\W+){1,2})?colored"_passed_cleaning    "coloreds?\W+((\w+\W+){1,2})?((was|were)\W+)?lynch(ed|es|ing)?(\W+|$)"\_passed_cleaning "lynchings?\W+of\W+(the\W+)?((\w+\W+){1,2})?negro"\_passed_cleaning "negro(e?s)?\W+((\w+\W+){1,2})?((was\|were)\W+)?lynch(ed\|es\|ing)?(\W+\|$)"_passed_cleaning    "mob\W+((\w+\W+){1,2})?(hung|hang(ed|ings?|s)|lynch(ed|es|ing)?)"_passed_cleaning    "(murderer|fiend|desperado|brute)\W+((\w+\W+){1,2})?lynch(ed|es|ing)?(\W+|$)"\_passed_cleaning