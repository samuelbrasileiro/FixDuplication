class FixStatementDuplication

  def initialize(projectPath, filePath, line, duplicatedMethod)
    @projectPath = projectPath
    @filePath = filePath
    @duplicatedMethod = duplicatedMethod
    @line = line
  end

  def fixDuplication()

    fileDirectory = Dir.getwd + "/" + @filePath

    #armazenar o conteudo do arquivo que esta faltando o metodo
    baseFileContent = File.read(fileDirectory).split("\n")
    counter = 0
    activated = false
    actual = @line - 1
    puts "Erased the following code segment:"
    if baseFileContent[actual].match(@duplicatedMethod)
      while !activated || counter > 0
        baseFileContent[actual].each_char do |c|
          if c == '{'
            counter += 1
            activated = true
          elsif c == '}'
            counter -= 1
          end
        end
        puts baseFileContent[actual]
        baseFileContent.delete_at(actual)
      end
    else
      puts "String not found"
    end

    baseFileContent = baseFileContent.join("\n")

    #escrever no arquivo
    e = File.open(fileDirectory, 'w')
    e.write(baseFileContent)
    e.close

    makeCommit
  end


  def makeCommit()
    #Dir.chdir(@projectPath)
    commitMesssage = "Build Conflict resolved automatic, removed " << @duplicatedMethod << " declaration in line " << @line << " of file " << @filePath
    %x(git add -u)
    %x(git commit -m "#{commitMesssage}")
  end

end
