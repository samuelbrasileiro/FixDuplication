class FixStatementDuplication

  def initialize(filePath, line, duplicatedMethod)
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
  end

end
