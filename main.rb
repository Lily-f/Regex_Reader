# See doc for notes a pseudo code

# set up method to read and store the regex. verify the regex is being read properly
# set up reading of strings that will be verified against the regex. 
# set up verification proccess. Test it. make tests?
# test against the given files. This step might need to be done sooner in the proccess to prevent wasted work
# write report or something i guess

# maybe create a class for each type of element and have a super type 'element'
File.foreach("words.txt") { |line| puts line}