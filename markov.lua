local Markov = {}
Markov.data = {}
Markov.starters = {}
Markov.enders = {}
Markov.totals = {
    words = {},
    starters = 0,
    enders = 0
}

function Markov:Learn(str)
    local wordArray = {}
    for word in str:gmatch("(%S+)") do
        wordArray[#wordArray + 1] = word
    end

    if wordArray[1] then
        self.starters[wordArray[1]] = self.starters[wordArray[1]] or 0
        self.starters[wordArray[1]] = self.starters[wordArray[1]] + 1
        self.totals.starters = self.totals.starters or 0
        self.totals.starters = self.totals.starters + 1
    end

    if wordArray[#wordArray] then
        self.enders[wordArray[#wordArray]] = self.enders[wordArray[#wordArray]] or 0
        self.enders[wordArray[#wordArray]] = self.enders[wordArray[#wordArray]] + 1
        self.totals.enders = self.totals.enders or 0
        self.totals.enders = self.totals.enders + 1
    end

    for i,word in ipairs(wordArray) do
        local nextWord = wordArray[i+1]
        if nextWord then
            self.data[word] = self.data[word] or {}
            self.data[word][nextWord] = self.data[word][nextWord] or 0
            self.data[word][nextWord] = self.data[word][nextWord] + 1
            self.totals.words[word] = self.totals.words[word] or 0
            self.totals.words[word] = self.totals.words[word] + 1
        end
    end
end

function Markov:getNextWord(word)
    if self.data[word] then
        local total = self.totals.words[word] or 0
        if total == 0 then return false end

        local target,val = math.random(1,total),0

        for nextWord,hits in pairs(self.data[word]) do
            if (nextWord ~= word) (val <= target) and ((val + hits) >= target) then return nextWord end
            val = val + hits
        end
    else
        return false
    end
end

function Markov:getStarterWord()
    local total = self.totals.starters
    if total == 0 then return false end

    local target,val = math.random(1,total),0

    for word,hits in pairs(self.starters) do
        if (val <= target) and ((val + hits) >= target) then return word end
        val = val + hits
    end
end

function Markov:getEndingProbability(word)
    if not self.enders[word] then return 0 end
    local total = self.totals.enders

    return self.enders[word]/total
end

function Markov:Generate(length,startingWord)
    local lastWord = startingWord or self:getStarterWord()
    local sentence = lastWord.." "
    if length then
        for i=1,length do
            lastWord = self:getNextWord(lastWord)
            if lastWord then
                sentence = sentence..lastWord.." "
            else
                break
            end
        end
    else
        while true do
            lastWord = self:getNextWord(lastWord)
            if lastWord then
                sentence = sentence..lastWord.." "
            else
                break
            end
        end
    end
    return sentence:sub(1,-2)
end

return Markov
