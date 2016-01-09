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
        local nextNextWord = wordArray[i+2]
        if nextWord and nextNextWord then
            self.data[word] = self.data[word] or {}
            self.totals.words[word] = self.totals.words[word] or {
                [0] = 0
            }
            if not self.data[word][nextWord] then
                self.data[word][nextWord] = {}
                self.totals.words[word][0] = self.totals.words[word][0] + 1
            end
            self.data[word][nextWord][nextNextWord] = self.data[word][nextWord][nextNextWord] or 0
            self.data[word][nextWord][nextNextWord] = self.data[word][nextWord][nextNextWord] + 1
            self.totals.words[word][nextWord] = self.totals.words[word][nextWord] or 0
            self.totals.words[word][nextWord] = self.totals.words[word][nextWord] + 1
        end
    end
end

function Markov:getNextWord(wordArray)
    local lastLastWord = wordArray[#wordArray-1]
    local lastWord = wordArray[#wordArray]

    --[[print("======")]]
    for i,v in ipairs(wordArray) do --[[print(i,v)]] end
    --[[print("")]]

    if not lastWord then
        --[[print("getNextWord failed: [1] ("..tostring(lastLastWord)..", "..tostring(lastWord)..")")]]
        return false
    end

    if not lastLastWord then
        if not self.data[lastWord] then
            --[[print("getNextWord failed: [2] ("..tostring(lastLastWord)..", "..tostring(lastWord)..")")]]
            return false
        end

        local total = self.totals.words[lastWord][0]
        local target,val = math.random(1,total),1
        for nextWord,_ in pairs(self.data[lastWord]) do
            if (val >= target) then return nextWord end
            val = val + 1
        end

        --[[print("getNextWord failed: [3] ("..tostring(lastLastWord)..", "..tostring(lastWord)..")")]]

        return false
    end

    if self.data[lastLastWord] and self.data[lastLastWord][lastWord] then
        local total = self.totals.words[lastLastWord][lastWord] or 0
        if total == 0 then
            --[[print("getNextWord failed: [4] ("..tostring(lastLastWord)..", "..tostring(lastWord)..")")]]
            return false
        end

        local target,val = math.random(1,total),1

        for nextWord,hits in pairs(self.data[lastLastWord][lastWord]) do
            --[[print(nextWord,val,val+hits,target,total)]]
            if (val <= target) and ((val + hits) > target) then return nextWord end
            val = val + hits
        end
    end

    --[[print("getNextWord failed: [5] ("..tostring(lastLastWord)..", "..tostring(lastWord)..")")]]
    return false
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

function Markov:Generate(startingWord,length)
    local wordArray = {startingWord or self:getStarterWord()}
    if length then
        for i=1,length do
            local nextWord = self:getNextWord(wordArray)
            if nextWord then
                wordArray[#wordArray+1] = nextWord
            else
                break
            end
        end
    else
        while true do
            local nextWord = self:getNextWord(wordArray)
            if nextWord then
                wordArray[#wordArray+1] = nextWord
            else
                break
            end
        end
    end
    return table.concat(wordArray," ")
end

return Markov
