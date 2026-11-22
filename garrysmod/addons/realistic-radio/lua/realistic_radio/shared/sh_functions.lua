/*
    Addon id: 2bab5356-b4ae-4c4d-acb8-e199f204bd54
    Version: v1.3.8 (stable)
*/

--[[ Make sure sentence exist and also langage exist]]
function Realistic_Radio.GetSentence(string)
    local result = "Lang Problem"
    local sentence = istable(Realistic_Radio.Language[Realistic_Radio.Lang]) and Realistic_Radio.Language[Realistic_Radio.Lang][string] or "Lang Problem"
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 5fa1e6df5fd1b55cf2f6f5dfb9364c1e6615d258fcc9159a1c9ab64208e71c95
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 90c45c83c06fd45965c506b0a40f9bf317f89c91d0aae2aa014fd2a772e64796
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968

    if istable(Realistic_Radio.Language[Realistic_Radio.Lang]) and isstring(sentence) then
        result = sentence
    elseif istable(Realistic_Radio.Language["en"]) and isstring(Realistic_Radio.Language["en"][sentence]) then
        result = Realistic_Radio.Language["en"][sentence]
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       /* 5fa1e6df5fd1b55cf2f6f5dfb9364c1e6615d258fcc9159a1c9ab64208e71c95 */
                                                                                                                                                                                                                                                                                                                                                                                                                                                       /* 76561199123350968 */

    return result
end
