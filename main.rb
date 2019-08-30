require_relative 'StatementDuplicationExtractor.rb'
require_relative 'BCStatementDuplication'
require_relative 'GitProject.rb'
require_relative 'FixStatementDuplication.rb'

if ARGV.length < 1
  puts "invalid args, valid args example: "
  puts "grumTreePath projectPath"
  puts "projectPath is an optional param"
  return
end


# Pre setup
puts "Entry your password"
password = STDIN.noecho(&:gets)

gumTree = ARGV[0]

if ARGV.length > 1
  Dir.chdir(ARGV[1])
end
projectPath = Dir.getwd

repLog = `#{"git config --get remote.origin.url"}`
if repLog == ""
  puts "invalid repository"
  return
end

projectName = repLog.split("//")[1]
projectName = projectName.split("github.com/").last.gsub("\n","").gsub(".git", "")
commitHash = `#{"git rev-parse --verify HEAD"}`
commitHash = commitHash.gsub("\n", "")
#print commitHash
print "\n"
# Init  Analysis
gitProject = GitProject.new(projectName, projectPath, "samuelbrasileiro", password)
conflictResult = gitProject.conflictScenario(commitHash) #aqui vamos pegar o parentMerge
#ESTRUTURA CR: [bool, [commits]]
gitProject.deleteProject()
#puts "conflictResult = #{conflictResult}"
if conflictResult[0] #se existir 2 parents

  conflictParents = conflictResult[1] #conflictParents = parentMerge
  #ESTRUTURA [PAI1,PAI2,FILHO]
  travisLog = gitProject.getTravisLog(commitHash)#pegar a log do nosso commit

  statementDuplicationExtractor = StatementDuplicationExtractor.new()
  unavailableResult = statementDuplicationExtractor.extractionFilesInfo(travisLog)


  #puts "unavailableResult = #{unavailableResult}"

  if unavailableResult[0] == "statementDuplication"

    conflictCauses = unavailableResult[1]

    ocurrences = unavailableResult[2]

    bcstatementDuplication = BCStatementDuplication.new(gumTree, projectName, projectPath, commitHash, conflictParents, conflictCauses)
    bcStDuplicationResult = bcstatementDuplication.getGumTreeAnalysis()

    #print("\bcStDuplicationResult = \n#{bcStDuplicationResult}\n")


    if bcStDuplicationResult[0] == true

      methodName = conflictCauses[0][3]
      conflictFile = conflictCauses[0][1]
      conflictFilePath = unavailableResult[3]
      fileToChange = conflictFilePath.gsub(/\/home\/travis\/build\/[^\/]+\/[^\/]+\//, "")
      conflictLine = unavailableResult[4]
      baseCommit = conflictResult[1][2]

      puts ">>>>>>>>>>>>>>>file "
      puts conflictFile
      puts ">>>>>>>>>>>>>>>fileToChange "
      puts fileToChange
      puts ">>>>>>>>>>>>>>>method"
      puts methodName
      puts ">>>>>>>>>>>>>>>line"
      puts conflictLine
      puts ">>>>>>>>>>>>>>>base"
      puts baseCommit
      puts "A build Conflict was detect, the conflict type is " + unavailableResult[0] + "."
      puts "Do you want fix it? y or n"
      resp = STDIN.gets()

      if resp != "n" && resp != "N"
        fixer = FixStatementDuplication.new(projectName, fileToChange, conflictLine, methodName)
        fixer.fixDuplication
      end

    end
  end
end

puts "FINISHED!"
