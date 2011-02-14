function perform_1() 
    -- write conference code here.
    -- this is the pin of the conference.
end 

function perform_2()
    -- write music code here. 
end 

function perform_3()
    -- write railway code here. 
end

session:answer()
base_url = "translate.google.com/translate_tts?q="
phrase_1 = base_url .. "Please+press+1+for+conference" .. "+Please+press+2+for+online+radio"
phrase_2 = base_url .. "Please+press+1+for+english+country" .. "+Please+press+2+3+4+5+for+hindi+songs"
while true do
    option = session:playAndGetDigits(1,5,3,7000, "#", "shout://" .. phrase_1, "", ".+")
    if option == "1" then 
        --pin = session:playAndGetDigits(1,5, 3, 7000, "#", "tone_stream://111111111111111111111111111111", "", ".+")
        --freeswitch.consoleLog("INFO", argv[1])
        --conference_name = argv[1] .. "+" .. pin
        --freeswitch.consoleLog("INFO", conference_name)
        conference_name = argv[1]
        session:execute("conference", conference_name)
    elseif option == "2" then
        choice = session:playAndGetDigits(1,5,3, 7000, "#", "shout://" .. phrase_2, "", ".+")
        if choice == "1" then 
            session:streamFile("shout://scfire-dtc-aa03.stream.aol.com/stream/1075")
        elseif choice == "2" then 
            session:streamFile("shout://216.235.91.36/play?s=bollywoodhungama")
        elseif choice == "3" then 
            session:streamFile("shout://87.98.216.140:80")
        elseif choice == "4" then 
            session:streamFile("shout://www.vtuner.com/vTunerweb/mms/m3u18290.m3u")
        elseif choice == "5" then 
            session:streamFile("shout://www.radiofiji.com.fj/asx/radiomirchi.asx")
        end
        if choice ~= "*" then 
            break
        end
    elseif option == "3" then
        session:execute("bridge", "user/5555")
        session:streamFile("tone_stream://##################")
        break
    end
end


