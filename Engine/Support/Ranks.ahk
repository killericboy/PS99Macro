; ▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰
; RANK CONFIGURATION FILE
; ----------------------------------------------------------------------------------------
; This file is used to map all games RANKS to RANK names.
; ▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰

RANK_DATA := Map()
RANK_DATA.Default := Map("Name", "-", "Regex", "")

RANK_DATA["1"] := Map("Name", "Noob", "Regex", "i)noob")
RANK_DATA["2"] := Map("Name", "Beginner", "Regex", "i)(beg|inn)")
RANK_DATA["3"] := Map("Name", "Rookie", "Regex", "i)(roo|kie)")
RANK_DATA["4"] := Map("Name", "Adventurer", "Regex", "i)adventurer")
RANK_DATA["5"] := Map("Name", "Experienced", "Regex", "i)experi")
RANK_DATA["6"] := Map("Name", "Pro", "Regex", "i)pro")
RANK_DATA["7"] := Map("Name", "Elite", "Regex", "i)elite")
RANK_DATA["8"] := Map("Name", "Expert", "Regex", "i)expert")
RANK_DATA["9"] := Map("Name", "Master", "Regex", "i)(?!.*min).*mast")
RANK_DATA["10"] := Map("Name", "Legend", "Regex", "i)(leg|gen)")
RANK_DATA["11"] := Map("Name", "Champion", "Regex", "i)(cham|pion)")
RANK_DATA["12"] := Map("Name", "Superstar", "Regex", "i)(sup|star)")
RANK_DATA["13"] := Map("Name", "Guardian", "Regex", "i)guardian")
RANK_DATA["14"] := Map("Name", "Titan", "Regex", "i)(?!.*tec).*tit")
RANK_DATA["15"] := Map("Name", "Sentinel", "Regex", "i)(?!.*tec).*sentinel")
RANK_DATA["16"] := Map("Name", "Overlord", "Regex", "i)(?!.*tec).*over")
RANK_DATA["17"] := Map("Name", "Immortal", "Regex", "i)imm")
RANK_DATA["18"] := Map("Name", "Hacker", "Regex", "i)(?!.*tec).*hack")
RANK_DATA["19"] := Map("Name", "Mastermind", "Regex", "i)mast")
RANK_DATA["20"] := Map("Name", "Ascendant", "Regex", "i)asc")
RANK_DATA["21"] := Map("Name", "Tech Titan", "Regex", "i)tec.*tit")
RANK_DATA["22"] := Map("Name", "Tech Sentinel", "Regex", "i)tec.*sent")
RANK_DATA["23"] := Map("Name", "Tech Overlord", "Regex", "i)tec.*over")
RANK_DATA["24"] := Map("Name", "Tech Hacker", "Regex", "i)tec.*hack")
RANK_DATA["25"] := Map("Name", "Omniscient", "Regex", "i)(om|nis|cient)")
RANK_DATA["26"] := Map("Name", "Celestial", "Regex", "i)cel")
RANK_DATA["27"] := Map("Name", "Apex", "Regex", "i)ape")
RANK_DATA["28"] := Map("Name", "Oracle", "Regex", "i)(ora|cle)")
RANK_DATA["29"] := Map("Name", "Void Walker", "Regex", "i)void walker")
RANK_DATA["30"] := Map("Name", "Warden", "Regex", "i)ward")
RANK_DATA["31"] := Map("Name", "Supreme Oracle", "Regex", "i)sup.*ora|ora.*sup")
RANK_DATA["32"] := Map("Name", "Radiant Titan", "Regex", "i)rank.?32")
RANK_DATA["33"] := Map("Name", "Ascendant Oracle", "Regex", "i)rank.?33")
RANK_DATA["34"] := Map("Name", "Eternal Seer", "Regex", "i)rank.?34")
RANK_DATA["35"] := Map("Name", "Transcendent Mind", "Regex", "i)rank.?35")
RANK_DATA["36"] := Map("Name", "Rank 36", "Regex", "i)rank.?36")
RANK_DATA["37"] := Map("Name", "Rank 37", "Regex", "i)rank.?37")
RANK_DATA["38"] := Map("Name", "Rank 38", "Regex", "i)rank.?38")
RANK_DATA["39"] := Map("Name", "Rank 39", "Regex", "i)rank.?39")
RANK_DATA["40"] := Map("Name", "Herald",  "Regex", "i)herald")

getRankDetails(ocrTextResult) {
    for rankKey, rankItem in RANK_DATA {
        if (regexMatch(ocrTextResult, rankItem["Regex"])) {
            return {rankNumber: rankKey, rankName: rankItem["Name"]}
        }
    }
    return {rankNumber: "-", rankName: "-"}
}