local Markov = {}
Markov.data = {}
Markov.starters = {}

function Markov:Learn(str)
    local wordArray = {}
    for word in str:gmatch("(%S+)") do
        wordArray[#wordArray + 1] = word
    end

    if wordArray[1] then
        self.starters[wordArray[1]] = self.starters[wordArray[1]] or 0
        self.starters[wordArray[1]] = self.starters[wordArray[1]] + 1
    end

    for i,word in ipairs(wordArray) do
        local nextWord = wordArray[i+1]
        if nextWord then
            self.data[word] = self.data[word] or {}
            self.data[word][nextWord] = self.data[word][nextWord] or 0
            self.data[word][nextWord] = self.data[word][nextWord] + 1
        end
    end
end

function Markov:getNextWord(word)
    if self.data[word] then
        local total = 0
        for word,hits in pairs(self.data[word]) do
            total = total + hits
        end

        if total == 0 then return false end

        local target,val = math.random(1,total),0

        for word,hits in pairs(self.data[word]) do
            val = val + 1
            if val == target then return word end
        end
    else
        return false
    end
end

function Markov:getStarterWord()
    local total = 0
    for word,hits in pairs(self.starters) do
        total = total + hits
    end

    if total == 0 then return false end

    local target,val = math.random(1,total),0

    for word,hits in pairs(self.starters) do
        val = val + 1
        if val == target then return word end
    end
end

function Markov:Generate(length,startingWord)
    local lastWord = startingWord or self:getStarterWord()
    local sentence = lastWord.." "
    for i=1,length or 5 do
        lastWord = self:getNextWord(lastWord)
        if lastWord then
            sentence = sentence..lastWord.." "
        else
            break
        end
    end
    return sentence:sub(1,-2)
end

return Markov
