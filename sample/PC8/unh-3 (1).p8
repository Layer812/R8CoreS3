pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

--touhou unmei no hoshi
--by chronocide
-- general
data_fill = {0b1111111111111111.1, 0b0111111111111111.1, 0b0111111111011111.1, 0b0101111111011111.1, 0b0101111101011111.1, 0b0101101101011111.1, 0b0101101101011110.1, 0b0101101001011110.1, 0b0101101001011010.1, 0b0001101001011010.1, 0b0001101001001010.1, 0b0000101001001010.1, 0b0000101000001010.1, 0b0000001000001010.1, 0b0000001000001000.1}
-- audio
data_perc = {"36610", "36615", "12043", "27323", "27313", "48615", "48610", "48613"}
data_sfx = {"0002200f01l2232xx3745424544454745444542453745424544454745444542453745424544454745444542453945404539453545f02l2232xx2030203020302030203020302030203020302030203020302030203020302030203020302331233023302330f04l2232xx2030203020302030203020302030203020302030203020302030203020302030203020301831183018301830f06l2232xx2030203020302030203020302030203020302030203020302030203020302030203020303930392542304225f07l2232xx4430442520142020203020302030203044304425201420203730372520142020203020304430442518144240f08l2232xx4225000040304025201420202030203020302030203020302030203020302030203020303940404039403540f09l2232x0403403403403403403393393393393393393373373373373373373274284274234f10l2232x0253253253253253253203203203203203203183183203203233233154164154114f11l2232x0133133133133133133203203203203203203153153153153153153272282272232f12l2232x0203203203203203203283283283283283283273273273273253253274284274234f13l2232x0252302322302322322252302322302322322252302322302322322272282272232f14l2232x0350000000000000000000000000000230250230200280270230250234254234204f15l2232x0284274234254254254254204234184204164184154164134154114134084084084fs1s2s3s4s503l2232xx1320132013201320132013201320132013201320132013201320132013201320132013201521152015201520f05l2232xx1320132013201320132013201320132013201320132013201320132013201320132013201121112011201120fs6s7s8s", "0000900fs103l2412x0153153153153152152163163163163162162133133133133132132153153153153152152f06l2412x0113113113113112112133133133133133133103103102102102102102102102102101101f09l2412x0113113113113112112143143143143142142153153153153153153152152152152152152f10l2412xx153015305145153015301530524516301630163052451630133013304935133013301330513515301530153051351530f11l2412xx113011304745113011301130494513301330133049451330103010304645103010301030464510301030103046451030f12l2412xx113011304745113011301130494513301330133049451330103010304645103010301030464510301030103046451030f13l2412x0000000474473374373464463354353444443440000474473374373464463354353350350f14l2412xx000000003540353038403830414041304640463050405030514051304640463044404430434644464340434043304330f15l2412x0190000354353384383414413384383354353344344344343343343394394394393393393f16l2412x0000000354353384383414413384383354353344344344344343343343343396375354344f1712xx3250324034503440355035403750374039503950394039404450445044404430445044504440443042504250445044503957375039503950394039403930393019123008081515080815150606131306061313040411110404111106061313060613132112x037537439539432532532432337537439539432532532432332532532432334534435535437537537437339537535534523123001010808010108080303101003031010040411110404111106061313080813132512x032432334434335435337437339439439339344439446439447449451444446446342442344444339439346447449449426124051474449464246474642394437394247473946374435423435373234353032342712x029429331431332432334434336436436336341436443436444446448441443443439439341441336443443344446446429123005051212050512120303101003031010010108080101080803031010030310103012x048444441446443439443444443439436441434436439444444336443434441432439431432434429431432427429431432123010101717101017171212191912121919131320201313202015152222151522223512xx295029403150314032503240345034403650364036503640415041504140413041504150414041303950395041504150365734503650365036403640363036303712x03443433643632942942932933443433643632942942932922942942942932932932922923143143133133663453243134103x02043243243243243243243243243243243243243243243243233233233233233233233233223223223223223223223224303x0174054054054054054054054054054054054054054054054053053053053053053053053052052052052052052052052s2s3s4s501l2412x0324354394444474514324354404444474524304344374424464494304344394424464514f02l2412x5233273323353393443233283323353403443223253303343373423223273303343393423f04l2412x0284324354404444474284324374404444494274314344394434464514464434344314274f05l2412x5203233283323353403203253283323373403193223273313343393433393343313273223f07l2412x0284324354404444474294344384414444504314344394434464514554584514464434394f08l2412x5203233283323353403203263293323383413223273313343393433463433393343313273f1812x03943244243444443544643744744744734734444434644635145134444435145134944934744734644633943934244232212x04444444434433743743733734644643434344344333943934744733943934644634744734944934244235434934734632812x03642943943144143244343444444444434434144134344334844834144134644634444434344333643633743733943933112x04144144134133443443433434344344334044044033643634444433643634344334444434644633943935144644444343312x036429439431441432443434444444444344341441343443341441441348448448346444443439441436439434436432434124034413741465153515248414037403634293132373941444946444339343231393612x03642943943144143244343444444444434434144134344334844834144134844834644634444434344333643633943933812x04144144134133443443433434344344334044044033643634444433643634344334444434644633943945164654444333912x04844145144345344445544645645645635635345335545535345545644845145134644634844835345334644845545534012x05645344845545144645344644844444644845144344445345334445144344444144343943644143243443642943243444203x0124244244244244244244244244244244244244244244244243243243243243243243243242242242242242242242242s6s7s82012002031043073082102112123141162191203233242262272283301p2412002031043073082102112123141162191203233242262272283303313ps", "0s102262013162025272832373940444039373027091316212325283537404951524451420526201115182327303539423937353027232120242732363944482427323639444851172630121912191118111212191219111811121219121911181112121912191118111221263016231623152315161623162315231516162316231523151616231623152315162326301219121911181112121912191118111212191219111811121219121915211827s2s30626251313131313131313131313131311111509090909090909090909090909090909072625111111111111111111111111111111111212121212121212151515151618192112263504110704110704110411070411070411041107041107041104110704110704111526252835283527332728283528352733272828352835273327282835283527332728162625241924192318232424192419231823242419241923182324241924192318232420262524192419231823242419241923182324241924192318232424192419273330392226xx04200420042004200420041004151605042004200420042004200410041516050420042004200420042004100415160504200420042004200420041004151605s4s50026x02052052042552752752742052852852842053053053053043253253253243243243233223212052553253052752352350126x01651651642052052052041652552552541652752752752742852852852842842842832822711652052852752351851850326xx255025502540285027502750274023502050205020402550255023502150215020502050205020402040203020302020245024502440155515551650165518500426xx165016501640205018501850184015501650165016402050205018501550155012501250125012401240123012301220205020502040125512551350135515500826x02552552542852752752742352052052042552552352152152052052052042042032032022452452452442442753053950926x01651651642051851851841551651651642052051851551551251251251241241231231222052052052042442753053951026503030302331313131333333233131313130303023313131313333332331313131112650181818111919191921212111191919191818181119191919212121111919191913265x19019519019518018518519019519519519518018518519019519519519518018518521021519019519518018518519514265x16016516016515015515516016516516516515015515516016516516516515015515518018516016516515015515516518265x19019519019518018518519019519519519518018518519019519519519518018518521021518519521515015515516519265x160165160165150155155160165165165165150155155160165165165165150155155180185155165185150155155165s6s7s8s", "0s103262000051017000712190108132000071219010813200310152201130315050912170426x00120821322020321021522220521221722422422412412410521321722520721521922720020721221921220720020720812200007031200070312000703120008031500050211000502110005021100070312142430031003100512051207140714071407140310031005120512020902090209020918243000070007020902090310031002090209031003100512051207150917111923262212300310061503100615031006150310061802080514020805140208051403100615s2s31524x5032102152222052122172242072142192262260260260260072152192272092172212292022092142212142092022092s419242500071219020914210310152202091421031015220512172403150517071114192312x52723412723412713412713412723512723512713512713512623212623212613212613212723412723412713412713412412x5152221152221151221151221152221152221151221151221152221152221151221151221152221152221151221151221s500025024242424242424242424242424242424272727272727272727272727272727270126xx295029502942293231503250365036502950295029422932285028502850284229503150325036503250315029503150325034503650395041504150414041350226xx295029502942293231503250365036502950295029422932292036504150435044504450415041504350435039503950365036503650365036423642362036100526xx204020402040204019401940194019402040204020402040194019401940194020402040204020401940194019401940204020402240224024402440243024250612552724192627312719242627313227292426232926232629262926232619242731071255121915171927241519192427272426202317262317232623232317231519242709125518171020222927301511182327272927292929262026262020202026222222271012xx245526552755315536553855395543552455265527553255365538553955445547554155395538553555385535552955275529553155365536503640363036251112xx19551955195527553155315531553955205520552055245532553255325536553855385536553555295529552955265524552655275531553150314031303125122450313131313334383831313131313843454646434345454141383838383838383813245027272727293134342626262626343838383834343636333330303030303030301624503131313133343838313131313030303031333438343331333436384143434343172450272727272931333322222222212121212224263126242224263133363838383820125518151017182218101517182223182015171420171417201720171417101518222112551510060810181506101015181815171514081714081417141414081406101518251255272218202230272222172730302729232620292620262926262620261822273026125527221822273030342217273030293035383230292629292626262227272727302712xx275529553055345539554155425546552755295530553555395541554255475550554455425541553855415538553255305532553455395539503940393039252812xx22552255225530553455345534554255235523552355275535553555355539554155415539553855325532553255295527552955305534553450344034303425s6s7s8s", "0s10226xx033003350300033003350300053005350330033503000330033503001130053003300335030003300335030005300535033003350300033003350300113005300526xx013001351100013001351100013001350530053505000530053505000530133003300335030003300335050005300535033003350300033003351000150017000826x0033103153173013083133153013063113133063100083030033103153173013103133153003083123153173183203173112630030810151110080601060813201813080308101502051014061113181315172015133003031010030310100303111103031111030312120303121203031111030311111813x0033033103103033033103103033033113113033033113113123123123122122122121121000000100100150150170170s2s3s412132503050610151718220305061115171823030506121517182403050611151718231913x5032052062102152172182222032052062112152172182232122050060120150170180240030050060110150170180230s50026x01001002242233043032942041001002242233043032942041001002242233043032942041001002242242233043043030126x00600601841832242234103200600601841832242231702000600601841832242231702000600601841841832242242230326x00600602242233043032942040800802242233043032942041001002242233043032942042242242232232222222742940426x00100101841832242234103200100101841832242234103200300301841832242234103201841841831831041541741840626x03043043033242942942933042742742732720002242742943043043033242942942933743443443433420003443743940726x01841841832041741741731841541541531520001041541741841841832041741741732542242242232220002242542740926xx324032353240324032353240344037403040303530403040303027402730294030403040303032402940294029302640274027402740273029402940293029401026xx204020352040204020352040224025401840183518401840183015401540174018401840183020401740174017301440154015401540153017401740173017401313x03043043043043033033033033023022943042942542242342442442442442432432432432422422422422412412412411413x01841841841841831831831831821821741841741341041141241241241241231231231231221221221221211211211211613x04244244244244244244244244244244143943743543443243643643643633633633623620000002242242742742942941713x0304304304304304304304304304304294274254234224204244244244243243243242242000000104104154154174174s6s7s8s",}
data_msc = {"0014010302000105040001030600010507000103080001050900010310000105110001031200010513000103130001051300010313000114600001156000", "002801020300040506000102030007080900010210000405110001021000070812000113100004141100011310000715120001131000041411000113100007161200171819202122232425181920262223243536292037383224272829203031322435332920373432242739292030403224414243mm", "0009000102mm030405mm0001020608090507101122mm101112mm13141521131416171314152118192023", "071800mmmmmm02mm04mm010503mm060708mm060708mm060708mm101108mm12131415161718191213141516161819202122mm202122mm202122242021222325202223252022232609222327282223", "0009000102mm030405mm060708mm091011mm131415121512mmmm1512mmmm16171819060708mm091011mm"}
-- enemy
data_enemy = {{name = "hong meiling", title = "gate keeper", lives = 2, hp = 250}, {name = "patchouli knowledge", title = "unmoving library", lives = 3, hp = 200}, {name = "fujiwara no mokou", title = "person of hourai", lives = 3, hp = 300}, {name = "remilia scarlet", title = "scarlet devil", lives = 4, hp = 350}}
data_spellcard = {"vivid chaotic dance", "alisma 3", "dragon's breath", "rainbow wind chime", "rise of phoenix", "metal sign: 'metal fatigue'", "water sign: 'lily in lake'", "earth sign: 'trilithon shake'", "fire & earth sign: 'lava cromlech'", "scarlet shoot", "curse of vlad tepes", "crimson rose", "millennium hell seal", "deafening flame whirlwind", "undying 'phoenix feathers'", "inextinguishable 'phoenix tail'", "demon empress"}
data_char = {{"reimu", "marisa"}, {"shrine maiden", "magician"}}
data_bullet = {"179001200001119000600002059000000004", "239001800006179001200007119000600008059000000009", "239001800018179001200014119000600016059000000015", "299002400010239001800011179001200012119000600017059000000013"}
data_movement = {"109000600034059990599899049000000034", "239992399899", "119000600033059990599899", "119000600033059990599899059000000033"}
-- credits to 𝘺ellow𝘢fterlife
-- https://www.lexaloffle.com/bbs/?tid=2420
-- scores are stored in the following format
-- 0:	𝘢
-- 1:	𝘢
-- 2:	𝘢
-- 3:	2
-- 4:	𝘢
-- 5:	𝘢
-- 6:	𝘢
-- 7:	2
-- max score something like 2147483647 probs idk
char = "abcdefghijklmnopqrstuvwxyz"
kb = {"abcdefghi", "jklmnopqr", "stuvwxyz"}
c2s = {}
s2c = {}
names = {}
scores = {}
kb_x = 1
kb_y = 1
score_mod = {0.5, 1, 1.33, 1.5}

function scores_get()
  for i = 1, 8 do
    local name = ""
    for j = 1, 3 do
      local char = dget(4 * (i - 1) + j)
      name = name .. c2s[char == 0 and 1 or char]
    end
    names[i] = name
    scores[i] = dget(4 * (i - 1))
  end
end

function score_init()
  for i = 1, #char do
    local s = sub(char, i, i)
    c2s[i] = s
    s2c[s] = i
  end
  scores_get()
end

function chr(i)
  return c2s[i + 1]
end

function score_draw(x, y)
  scores_get()
  for i = 1, 8 do
    bprint(names[i] .. " : " .. scores[i], x, i * 8 + y, 15, 1)
  end
end

function score_clear()
  for i = 0, 63 do
    dset(i, 0)
  end
end

function score_set(name, score)
  names[9] = name
  scores[9] = flr(score)
  -- credits to impbox
  -- https://www.lexaloffle.com/bbs/?pid=14233#p
  for i = 0, #scores do
    local j = i
    while j > 1 and scores[j - 1] < scores[j] do
      scores[j], scores[j - 1] = scores[j - 1], scores[j]
      names[j], names[j - 1] = names[j - 1], names[j]
      j = j - 1
    end
  end
  for i = 1, 7 do
    dset((i - 1) * 4, scores[i])
    for j = 1, 3 do
      dset((i - 1) * 4 + j, s2c[sub(names[i], j, j)])
    end
  end
  score = 0
end

function score_draw_kb(x, y)
  for i = 1, #kb do
    for j = 1, #kb[i] do
      bprint(sub(kb[i], j, j), (j - 1) * 8 + x, (i - 1) * 8 + y, 15, 1)
      -- y - 2 + (kb_y - 1) * 8,
      -- y + 6 + (kb_y - 1) * 8,
      if kb_x == j and kb_y == i then
        rect(x - 2 + (kb_x - 1) * 8, y + 6 + (kb_y - 1) * 8, x + 4 + (kb_x - 1) * 8, y + 6 + (kb_y - 1) * 8, 15)
      end
    end
  end
end

-- globals
audio_track = 1
audio_busy = false

function audio_reset()
  for i = 0, 59 do
    poke(0x3243 + 68 * i, 0)
    for j = 0, 31 do
      poke(0x3201 + j * 2 + 68 * i, 0)
    end
  end
end

function audio_readsfx(pattern)
  audio_busy = true
  audio_reset()
  local offset = 1
  for i = 0, 8 do
    if i < 8 then
      -- instrument channels
      offset += 1
      if sub(pattern, offset + 1, offset + 1) ~= "s" then
        -- check instrument stop
        for j = 0, 63 do
          -- loop channels
          if sub(pattern, offset, offset) ~= "s" then
            -- check instrument stop
            -- id
            local id = sub(pattern, offset, offset + 1)
            offset += 2
            -- check loop
            if sub(pattern, offset, offset) == "l" then
              poke(0x3243 + 68 * id, sub(pattern, offset + 1, offset + 2))
              offset += 3
            end
            -- speed(?)
            poke(0x3241 + 68 * id, sub(pattern, offset, offset + 1))
            offset += 2
            -- volume
            local tvol = sub(pattern, offset, offset)
            offset += 1
            -- effect
            local teff = sub(pattern, offset, offset)
            offset += 1
            -- loop notes
            for k = 0, 31 do
              if sub(pattern, offset, offset) ~= "f" then
                -- check repeated pitch
                -- pitch
                local pitch = sub(pattern, offset, offset + 1)
                offset += 2
                -- volume
                local vol
                if tvol == "x" then
                  vol = sub(pattern, offset, offset)
                  offset += 1
                else
                  vol = tvol
                end
                -- effect
                local eff
                if teff == "x" then
                  eff = sub(pattern, offset, offset)
                  offset += 1
                else
                  eff = teff
                end
                -- insert data
                poke(0x3200 + k * 2 + 68 * id, pitch + 64 * (i % 4))
                poke(0x3201 + k * 2 + 68 * id, 16 * eff + 2 * vol + (i / 4))
              else
                if k == 31 then
                  offset += 1
                end
              end
            end
          else
            if j == 63 then
              offset += 1
            end
          end
        end
      end
    else
      -- percussion channel
      offset += 1
      if sub(pattern, offset, offset) ~= "s" then
        -- check empty
        for j = 0, 63 do
          -- loop channels
          if sub(pattern, offset, offset) ~= "s" then
            -- id
            local id = sub(pattern, offset, offset + 1)
            offset += 2
            -- check loop
            if sub(pattern, offset, offset) == "l" then
              poke(0x3243 + 68 * id, sub(pattern, offset + 1, offset + 2))
              offset += 3
            end
            -- speed
            poke(0x3241 + 68 * id, sub(pattern, offset, offset + 1))
            offset += 2
            -- loop samples
            for k = 0, 31 do
              if sub(pattern, offset, offset) ~= "p" then
                local index = sub(pattern, offset, offset + 1)
                if tonum(index) == k then
                  offset += 2
                  -- sample
                  local sample = data_perc[tonum(sub(pattern, offset, offset)) + 1]
                  offset += 1
                  -- get data
                  local pitch = sub(sample, 1, 2)
                  local inst = sub(sample, 3, 3)
                  local vol = sub(sample, 4, 4)
                  local eff = sub(sample, 5, 5)
                  -- set data
                  poke(0x3200 + k * 2 + 68 * id, pitch + 64 * (inst % 4))
                  poke(0x3201 + k * 2 + 68 * id, 16 * eff + 2 * vol + (inst / 4))
                end
              end
            end
            offset += 1
          end
        end
      end
    end
  end
  audio_busy = false
end

function audio_readmsc(pattern)
  local start = tonum(sub(pattern, 1, 2))
  local stop = tonum(sub(pattern, 3, 4))
  local offset = 5
  for i = 0, 32 do
    for j = 0, 3 do
      local sfx = sub(pattern, offset, offset + 1)
      if sfx == "mm" then
        sfx = 64
      end
      poke(0x3100 + j + i * 4, sfx)
      offset += 2
    end
  end
  poke(0x3100 + start * 4, peek(0x3100 + start * 4) + 128)
  poke(0x3101 + stop * 4, peek(0x3101 + stop * 4) + 128)
end

function audio_play(i)
  if not audio_busy then
    audio_readsfx(data_sfx[i])
    audio_readmsc(data_msc[i])
    music(0)
    audio_track = i
  end
end

function audio_sfx(i)
  if i == 1 then
    sfx(63, 3, 0, 2)
  end
  -- menu up/down
  if i == 2 then
    sfx(63, 3, 25, 8)
  end
  -- menu select
  if i == 3 then
    sfx(63, 3, 17, 8)
  end
  -- menu back
  if i == 4 then
    sfx(63, 3, 2, 2)
  end
  -- shoot
  if i == 5 then
    sfx(63, 3, 4, 5)
  end
  -- hit
  if i == 6 then
    sfx(62, 3, 0, 7)
  end
-- bomb
end

-- general
function rm_trail(str)
  for i = 1, #str do
    local slice = sub(str, i, i)
    if slice ~= "0" then
      str = sub(str, i, #str)
      break
    end
  end
  return tonum(str)
end

-- str
function str_cx(str, x)
  x = x or 64
  return x - #str * 2
end

-- print
function cprint(str, y, c)
  print(str, str_cx(str), y, c)
end

function bprint(str, x, y, c1, c2)
  if x == "c" then
    x = str_cx(str)
  end
  for i = -1, 1 do
    for j = -1, 1 do
      print(str, x + i, y + j, c2)
    end
  end
  print(str, x, y, c1)
end

-- draw
function draw_border(y, w, h, c)
  rectfill(0 + w, y, 127 - w, y + h, c or 15)
end

function draw_btn(str, x, y, xoff, yoff, c1, c2)
  if level_t < 0.5 then
    bprint(str, x, y, c2 or 1, c2 or 1)
    bprint(str, xoff and x + xoff or x, yoff and y + yoff or y - 1, c1 or 15, c2 or 1)
  else
    bprint(str, x, y, c1 or 15, c2 or 1)
  end
end

function draw_list(list, x, y, active)
  local c, y𝘰ffset
  for k, v in pairs(list) do
    y𝘰ffset = y + k * 8
    x𝘰ffset = #v * 2 + 16
    if active == k then
      c = 15
      draw_btn("❎", 60 - x𝘰ffset, y𝘰ffset)
      draw_btn("❎", 60 + x𝘰ffset, y𝘰ffset)
    else
      c = 13
    end
    bprint(v, x, y𝘰ffset, c, 1)
  end
end

function draw_carpet(x, y)
  spr(142, x, y, 2, 2, false, true)
  -- top right
  spr(142, x + 16, y, 2, 2, true, true)
  spr(142, x, y + 16, 2, 2)
  -- bottom left
  spr(142, x + 16, y + 16, 2, 2, true)
-- bottom right
end

function draw_splash(x, y)
  spr(12, x + 4, y, 4, 3)
  spr(58, x, y + 24, 5, 5)
end

function draw_kanji(x, y)
  for i = 0, 3 do
    spr(8 + i * 32, x + i * 16, y, 2, 2)
  end
  spr(10, x + 64, y, 2, 2)
end

function draw_avatar(n, x, y, active, c)
  pal(11, 3)
  palt(3, false)
  if active then
    c = 15
    draw_btn(">", x - 8, y + 8, 1, 0)
    draw_btn("<", x + 22, y + 8, -1, 0)
  else
    c = c or 1
  end
  rect(x, y, x + 17, y + 17, c)
  spr(n * 2 + 192, x + 1, y + 1, 2, 2)
  pal()
end

function draw_select_char(n, x, y, active)
  local name = data_char[1][n]
  local title = data_char[2][n]
  local action = "❎ select"
  bprint(name, str_cx(name, x), y, 15, 1)
  bprint(title, str_cx(title, x), y + 9, 15, 1)
  draw_avatar(15 + n, x - 10, y + 19, active)
  if active then
    draw_btn(action, str_cx(action, x - 3), y + 43)
  end
end

function draw_dialog(txt, y)
  draw_border(y, 0, 24, 0)
  cprint(txt, y + 4, 7)
  draw_btn("❎ continue", 41, y + 14, 0, -1, 7, 0)
end

function draw_char_title(y)
  draw_border(y, 0, 19, 0)
  draw_avatar(18 + level_index(), 16, y + 1, false, 0)
  print(data_enemy[level_index() + 1].name, 38, y + 4, 7)
  print(data_enemy[level_index() + 1].title, 38, y + 11, 7)
  local str = "❎ start"
  draw_btn(str, str_cx(str), y + 23, 0, -1, 7, 0)
end

level_x = 0
level_y = 0
level_t = 0
level_s = 0
level_bg = 9

function level_index()
  return level_x % 8 + level_y * 8
end

function level_set(x, y, track)
  level_x = x
  level_y = y
  paused = true
  if track then
    audio_play(track)
  end
end

function level_next()
  level_x = level_x + 1
  paused = true
  player_x = 60
  player_y = 91
  player_bullets = {}
  enemy_create(level_index())
  audio_play(audio_track + 1)
end

-- update
function level_update()
  level_t = ((level_t + 1 / 99) % 1)
  if not player_dead or not paused then
    level_s = ((level_s + 1) % 64)
  end
end

-- draw
function level_draw_title()
  rectfill(0, 0, 127, 127, 1)
  for i = 1, 16 do
    fillp(data_fill[i])
    rectfill(0, 44 + (i * 5), 127, 48 + (i * 5), 2)
  end
  fillp()
end

function level_draw_bg()
  if level_index() == 0 then
    level_bg = 9
  end
  if level_index() == 1 then
    level_bg = 1
  end
  if level_index() == 2 then
    level_bg = 2
  end
  if level_index() == 3 then
    level_bg = 2
  end
  rectfill(0, 0, 127, 127, level_bg)
end

function level_draw_map()
  for i = 0, 128, 128 do
    local y = (level_s * 2) - i
    map(level_x * 16, level_y * 16, 0, y, 16, 16)
    if level_index() > 0 and level_index() ~= 2 then
      circfill(63, y + 14, 32, 2)
      circfill(63, y + 14, 27, 4)
      circfill(63, y + 14, 20, 9)
    end
    if level_index() ~= 2 then
      draw_carpet(48, y - 2)
    end
  end
end

function level_draw()
  level_draw_bg()
  if level_index() >= 16 then
    level_draw_title()
  else
    level_draw_map()
  end
end

function list_iter(l)
  return l[flr(enemy_itr / 2 % #l + 1)]
end

function list_rnd(l)
  return l[flr(rnd(#l) + 1)]
end

function pattern_bullet()
  --[[
	n:	#bullets per t
	t:	pause between wave
	start:	starting angle
		0    = right
		0.25 = up
		0.5  = left
		0.75 = down
	speed: velocity of bullets
	sprd:  spread of bullets
		-- rationals
		0     = no spread
		0.5   = 2 lines
		0.25  = 4 lines
		0.05  = half circle
		0.025 = quarter circle
		-- irrationals
		0.618 = sunflower
		0.314 = almost sunflower
		0.550 = solar explosion
		0.012 = 1x tendril
		0.502 = 2x tendril
		0.333 = 3x tendril
		0.834 = 6x tendril
		0.428 = 7x tendril
	angle: angle of bullets(group) 
	color: bullet sprite
	homin: bullet follows player
]]
  if enemy_b == 0 then
    enemy_tbul = 1
    enemy_itr = 0
  end
  if enemy_b == 1 then
    -- meiling: vivid chaotic dance
    local a = {96, 98, 99, 100}
    pal(12)
    return (6000 - enemy_time) / 600, 2, 0, 0.75, 0.834, 0.618, list_iter(a), false
  end
  if enemy_b == 2 then
    -- meiling: alisma 3
    local a = {0.01, -0.01}
    local b = {96, 100, 101}
    return 2, 2, enemy_tbul / 250, 0.5, 0.33, list_iter(a), list_rnd(b), false
  end
  if enemy_b == 3 then
    -- meiling: dragon's breath
    local a = {98, 96, 97}
    local b = {-1, 0, 1}
    return enemy_itr / 4, 1 + flr(enemy_itr / 8), list_iter(b) * enemy_tbul / 500, 0.25 + enemy_itr / 40, 0.0025, 0, list_rnd(a), true
  end
  if enemy_b == 4 then
    -- meiling: rainbow wind chime
    local a = {100, 96, 101}
    return 1, 1, frame / 3, 0.5, 0.124, 0.512, list_iter(a), false
  end
  if enemy_b == 5 then
    -- fujiwara no mokou: rise of phoenix
    local a = {98, 96, 97}
    return 20, (frame / 120) ^ 10, 0.75, (60 / frame), 0.550 + (frame / 360 / enemy_itr), frame / 120, a[flr(rnd(#a) + 1)], false
  end
  if enemy_b == 6 then
    -- patchouli: metal sign "metal fatigue"
    local a = {102, 118}
    return 6, 3, enemy_time / 100, 1, 0.456, 0.456, list_iter(a), false
  end
  if enemy_b == 7 then
    -- patchouli: water sign "lily in lake"
    local a = {100, 101}
    return 10 + (6000 - enemy_time) / 600, 3, 0.95 + (frame % 0.003), 1, 0.1, flr(frame % 2) * 0.314, a[frame % 2 + 1], frame % 2 == 0
  end
  if enemy_b == 8 then
    -- patchouli: earth sign: "trilithon shake"
    local b = {102, 18, 50}
    return 7, 3, 1, 1, 0.73, ((300 / frame) / enemy_time) + (0.75 + (-1) ^ 0.5), b[flr(enemy_itr / 2 % #b + 1)], false
  end
  if enemy_b == 9 then
    -- patchouli: fire & earth sign: "lava cromlech"
    return 4, 2, enemy_time / 999, 1, enemy_time / 10, enemy_time / 100, 99, false
  end
  if enemy_b == 10 then
    -- remilia: scarlet shoot
    return frame % 5 == 0 and 30 or 2, 16, 1, 1, frame % 5 == 0 and 0.618 or 0.01, 1, frame % 5 == 0 and 112 or 34, true
  end
  if enemy_b == 11 then
    -- remilia: curse of vlad tepes
    return 5, 3, 0.95 + (frame % 0.314), 1, 0.313, 0.1, frame % 5 == 0 and 112 or 34, false
  end
  if enemy_b == 12 then
    -- remilia: crimson rose
    return 4, 2, enemy_time / 3, 0.75, frame / 314, 0.314, frame % 3 == 0 and 34 or 18, false
  end
  if enemy_b == 13 then
    -- remilia: millenium hell seal
    -- use rotation
    return 2, 1, frame / 2, 0.75, 0.314, -0.550, 96, false
  end
  if enemy_b == 14 then
    -- mokou: deafening flame whirlwind
    return 2, 1, frame / 36, enemy_time / 6000, 0.415, 0.550, 34, false
  end
  if enemy_b == 15 then
    -- mokou: inextinguishable "phoenix tail"
    -- use rotation
    return 2, 1, frame / 36, 6000 / enemy_time, 0.314, -0.5, 34, false
  end
  if enemy_b == 16 then
    -- mokou: flame sign "phoenix's feathers"
    local b = {18, 34}
    return 7, 3, enemy_time / 104, 0.75, 0.777, 0.512, b[flr(enemy_itr / 2 % #b + 1)], false
  end
  if enemy_b == 17 then
    -- remilia: hell sign "demon empress"
    local b = {96, 112}
    return 3, 1, enemy_time / 6000, 1, 0.033, 0.550, 96, false
  end
  if enemy_b == 18 then
    -- mokou: possessed by phoenix
    return 3, 1, 1, 0.8, 0.888, 0.550, 18, false
  end
end

function pattern_movement(p)
  --[[
	s: speed
		1: 128 frames (full screen)
		128: 1 frame (full screen)
	a: angle
		up:   0.25
		left: 0.5
		down: 0.75
		right:1
]]
  if p == 0 then
    enemy_tmov = 1
  end
  local m = p - 1
  if p > 0 and p <= 16 then
    -- cardinal directions (regular)
    return 1, 0.0625 * m
  end
  if p > 16 and p <= 32 then
    -- cardinal directions (fast)
    return 2, 0.0625 * m
  end
  if p == 33 then
    -- rotate (60 = 1 rot)
    return 2, enemy_tmov / 30.5
  end
  if p == 34 then
    -- 𝘥ouble spawners
    return 40, (0.75 + (-1) ^ flr(frame + frame / 4) * 0.25)
  end
  if p == 99 then
    -- 𝘳eset position
    enemy_tmov = 1
    enemy_x = 62
    enemy_y = 20
  end
end

enemy_name = ""
enemy_lives = 1
enemy_spr = 1
enemy_maxhp = 1
enemy_time = 6000
enemy_ttime = 0
enemy_tmov = 1
enemy_x = 0
enemy_y = 0
enemy_pattern = {}
enemy_movement = {}
enemy_bullets = {}
enemy_itr = 0
enemy_tbul = 1
enemy_dead = false

function decode(input, output)
  for i = 1, #input, 12 do
    -- slice input, remove trail
    local slice = sub(input, i, i + 11)
    local time_start = rm_trail(sub(slice, 1, 5))
    local time_end = rm_trail(sub(slice, 6, 10))
    local pattern = rm_trail(sub(slice, 11, 12))
    -- input in table
    for j = time_end, time_start do
      output[j] = pattern
    end
  end
end

-- init
function enemy_reset()
  enemy_x = 62
  enemy_y = 24
  enemy_time = 6000
  -- 1 minute
  enemy_hp = enemy_maxhp
end

function enemy_create(id)
  enemy_name = data_enemy[id].name
  enemy_spr = id * 2 + 62
  enemy_lives = data_enemy[id].lives
  enemy_maxhp = data_enemy[id].hp
  enemy_bullets = {}
  enemy_b = 0
  enemy_reset()
  for i = 1, enemy_time * (enemy_lives + 1) do
    -- fill with empty
    enemy_pattern[i] = 0
    enemy_movement[i] = 0
  end
  -- decode patterns
  decode(data_bullet[id], enemy_pattern)
  decode(data_movement[id], enemy_movement)
end

-- update
function enemy_move()
  local m = enemy_movement[enemy_ttime]
  local s, a = pattern_movement(m)
  if m ~= 0 and m ~= 99 then
    enemy_tmov += 1
    enemy_x += s * cos(a)
    enemy_y += s * sin(a)
  end
end

function enemy_bullet(i, start, speed, sprd, rot, col, homing)
  local a = start + (sprd * i) + (rot * enemy_itr)
  if homing then
    a = start + atan2(player_x - enemy_x, player_y - enemy_y) + (sprd * i)
  end
  return {x = enemy_x, y = enemy_y, vel_x = speed * cos(a), vel_y = speed * sin(a), spr = col}
end

function enemy_shoot()
  enemy_b = enemy_pattern[enemy_ttime]
  if enemy_b ~= 0 then
    local n, t, start, speed, sprd, rot, col, homing = pattern_bullet()
    if frame % t == 0 then
      audio_sfx(4)
      enemy_tbul += 1
      enemy_itr += 1
      for i = 0, n do
        add(enemy_bullets, enemy_bullet(i, start, speed, sprd, rot, col, homing))
      end
    end
  end
end

function enemy_update()
  enemy_time -= 1
  enemy_ttime = enemy_time + (enemy_lives * 6000)
  if enemy_time <= 0 or enemy_hp <= 0 then
    if enemy_lives > 0 then
      enemy_reset()
    end
    enemy_lives -= 1
  end
  score += 1
end

-- draw
function enemy_drawmarker()
  bprint("\94", enemy_x, 124, 7, 0)
end

function enemy_draw()
  palt(12, true)
  palt(3, false)
  spr(enemy_spr, enemy_x - 6, enemy_y - 6, 2, 2)
  palt(12, false)
  palt(3, true)
  for bullet in all(enemy_bullets) do
    spr(bullet.spr, bullet.x, bullet.y)
  end
end

player_spr = 0
player_bul = 0
player_x = 0
player_y = 0
player_lives = 0
player_livesmax = 0
player_speed = 1
player_bullets = {}
player_bomb = 3
player_grace = 3
player_damage = 1
player_hit = false
player_dead = false

-- init
function player_reset()
  player_bullets = {}
  player_x = 60
  player_y = 91
  player_hit = false
end

function player_create(id)
  player_reset()
  player_dead = false
  player_spr = id
  player_bul = 16 + id
  player_damage = id == 0 and 1 or 1.33
  player_lives = 5 - mode
  player_livesmax = player_lives
end

-- update
function player_collision()
  local c = pget(player_x + 2 + player_spr, player_y + 4)
  if c ~= 11 then
    player_grace -= 1
  else
    player_grace = 3
  end
  if player_grace == 0 then
    player_grace = 3
    player_lives -= 1
    if player_lives <= 0 then
      player_dead = true
    end
    player_hit = true
  end
end

function player_input()
  -- left
  if btn(0) then
    player_x -= player_speed
    if player_x <= 0 then
      player_x = 0
    end
  end
  -- right
  if btn(1) then
    player_x += player_speed
    if player_x >= 120 then
      player_x = 120
    end
  end
  -- up
  if btn(2) then
    player_y -= player_speed
    if player_y <= 0 then
      player_y = 0
    end
  end
  -- down
  if btn(3) then
    player_y += player_speed
    if player_y >= 120 then
      player_y = 120
    end
  end
  -- bomb
  if btnp(4) and player_bomb ~= 0 then
    player_bomb -= 1
    enemy_bullets = {}
    audio_sfx(6)
  end
  -- shoot
  if btn(5) then
    player_speed = player_spr == 0 and 0.33 or 0.5
    if frame % 5 == 0 then
      add(player_bullets, {x = player_x, y = player_y})
      audio_sfx(4)
    end
  else
    player_speed = 1
  end
end

-- draw
function player_draw()
  for bullet in all(player_bullets) do
    spr(player_bul, bullet.x, bullet.y)
  end
  spr(player_spr, player_x, player_y)
end

function bullets_player()
  for bullet in all(player_bullets) do
    bullet.x += 2 * cos(0.25)
    bullet.y += 2 * sin(0.25)
    -- collision
    if bullet.y <= enemy_y + 7 and bullet.x <= enemy_x + 9 and bullet.x >= enemy_x - 12 then
      enemy_hp -= player_damage
      del(player_bullets, bullet)
      audio_sfx(5)
    end
    -- cleanup
    if bullet.y < -8 then
      del(player_bullets, bullet)
    end
  end
end

function bullets_enemy()
  for bullet in all(enemy_bullets) do
    bullet.x += bullet.vel_x
    bullet.y += bullet.vel_y
    -- check out of bounds
    if bullet.x <= -7 or bullet.x >= 127 then
      del(enemy_bullets, bullet)
    end
    if bullet.y <= -7 or bullet.y >= 127 then
      del(enemy_bullets, bullet)
    end
  end
end

ui_cur = 1
ui_page = 1
ui_pressed = false
ui_score_name = ""
ui_t = 60
ui_txt = {{"start", "practice", "high score", "music room", "options"}, {"stage 1: entrance", "stage 2: library", "stage 3: tower", "stage 4: balcony"}, {"intro theme", "meiling's theme", "patchouli's theme", "mokou's theme", "remilia's theme"}, {"easy", "normal", "hard", "lunatic"}, {"0.5x score | 4 lives", "1x score | 3 lives", "1.33x score | 2 lives", "1.5x score | 1 life"}}

function ui_handle_nav(cbaction, menu)
  -- up
  if btnp(2) then
    ui_cur -= 1
    audio_sfx(1)
  end
  -- down
  if btnp(3) then
    ui_cur += 1
    audio_sfx(1)
  end
  -- action
  if btnp(5) and not ui_pressed then
    ui_pressed = true
    cbaction()
    audio_sfx(2)
  end
  if ui_cur < 1 then
    ui_cur = #menu
  end
  if ui_cur > #menu then
    ui_cur = 1
  end
end

function ui_handle_title()
  ui_page += ui_cur
  ui_cur = 1
end

function ui_handle_practice()
  mode = 0
  player_bomb = 3
  player_create(0)
  enemy_create(ui_cur)
  level_set(ui_cur - 1, 0, ui_cur + 1)
end

function ui_handle_music()
  audio_play(ui_cur)
end

function ui_handle_options()
  mode = ui_cur
end

function ui_update_title()
  -- back
  if btnp(4) then
    ui_cur = ui_page - 1
    ui_page = 1
    audio_sfx(3)
  end
  -- nav
  ui_pressed = false
  if ui_page == 1 then
    ui_handle_nav(ui_handle_title, ui_txt[1])
  end
  -- title
  if ui_page == 2 then
    -- start
    -- left
    if btnp(0) then
      ui_cur -= 1
      audio_sfx(1)
    end
    -- right
    if btnp(1) then
      ui_cur += 1
      audio_sfx(1)
    end
    -- action
    if btnp(5) and not ui_pressed then
      ui_pressed = true
      player_create(ui_cur - 1)
      enemy_create(1)
      audio_sfx(2)
      level_set(0, 0, 2)
    end
    if ui_cur < 1 then
      ui_cur = 2
    end
    if ui_cur > 2 then
      ui_cur = 1
    end
  end
  if ui_page == 3 then
    ui_handle_nav(ui_handle_practice, ui_txt[2])
  end
  -- practice
  if ui_page == 5 then
    ui_handle_nav(ui_handle_music, ui_txt[3])
  end
  -- music room
  if ui_page == 6 then
    ui_handle_nav(ui_handle_options, ui_txt[4])
  end
  -- options
  if ui_page == 7 then
    -- results
    -- left
    if btnp(0) then
      kb_x -= 1
      audio_sfx(1)
    end
    -- right
    if btnp(1) then
      kb_x += 1
      audio_sfx(1)
    end
    -- up
    if btnp(2) then
      kb_y -= 1
      audio_sfx(1)
    end
    -- down
    if btnp(3) then
      kb_y += 1
      audio_sfx(1)
    end
    -- action
    if btnp(5) then
      if (#ui_score_name < 3) then
        local offset = kb_y == 1 and 0 or #kb[kb_y - 1] * (kb_y - 1)
        ui_score_name = ui_score_name .. chr(kb_x + offset - 1)
      else
        if mode ~= 0 then
          score_set(ui_score_name, score * score_mod[mode])
        end
        ui_page = 1
      end
    end
    -- overflow
    if kb_y < 1 then
      kb_y = #kb
    end
    if kb_y > #kb then
      kb_y = 1
    end
    if kb_x < 1 then
      kb_x = #kb[kb_y]
    end
    if kb_x > #kb[kb_y] then
      kb_x = 1
    end
  end
end

function ui_update_dead()
  ui_page = mode == 0 and 1 or 7
  ui_score_name = ""
  level_set(0, 2, 1)
end

function ui_update_hit()
  player_x = 60
  player_y = 91
  enemy_bullets = {}
  player_hit = false
  paused = false
end

function ui_update_paused()
  paused = false
end

function ui_update()
  if level_index() >= 16 then
    ui_update_title()
  else
    if btnp(5) then
      audio_sfx(2)
      if paused then
        ui_update_paused()
      end
      if player_dead then
        ui_update_dead()
      end
      if player_hit then
        ui_update_hit()
      end
    end
  end
end

-- draw
function ui_draw_title()
  if ui_page == 1 then
    -- main screen
    draw_splash(42, cos(level_t) * 2 + 26)
    draw_kanji(25, 37)
    bprint("~ unmei no hoshi ~", "c", 55, 15, 1)
    bprint("game by:@chronodave", "c", 120, 15, 1)
    draw_list(ui_txt[1], "c", 61, ui_cur)
  else
    draw_kanji(25, 5)
    bprint("~ unmei no hoshi ~", "c", 23, 15, 1)
    draw_border(35, 0, 10)
    draw_btn("🅾️ back", "c", 120)
  -- main menu
  end
  -- start
  if ui_page == 2 then
    cprint("choose character", 38, 1)
    draw_select_char(1, 37, 55, ui_cur == 1)
    draw_select_char(2, 91, 55, ui_cur == 2)
  end
  -- practice
  if ui_page == 3 then
    cprint("choose stage", 38, 1)
    draw_list(ui_txt[2], "c", 69, ui_cur)
    draw_avatar(ui_cur + 17, 55, 53)
  end
  -- high score
  if ui_page == 4 then
    cprint("high scores", 38, 1)
    score_draw(30, 45)
  end
  -- music room
  if ui_page == 5 then
    cprint("current: " .. ui_txt[3][audio_track], 38, 1)
    draw_list(ui_txt[3], "c", 59, ui_cur)
  end
  -- options
  if ui_page == 6 then
    cprint("difficulty: " .. ui_txt[4][mode], 38, 1)
    bprint(ui_txt[5][mode], "c", 50, 15, 1)
    draw_list(ui_txt[4], "c", 59, ui_cur)
  end
  -- game over
  if ui_page == 7 then
    print("enter name:", 40, 38, 1)
    print(ui_score_name, 84, 38, 1)
    score_draw_kb(28, 60)
    if #ui_score_name == 3 then
      draw_btn("❎ save", 68, 87)
    end
  end
end

function ui_draw_level()
  -- enemy
  rect(1, 2, 126, 2, 5)
  -- inside
  rect(1, 2, enemy_hp / enemy_maxhp * 125 + 1, 2, 7)
  -- hp
  rect(1, 1, 126, 3, 0)
  -- border
  for i = 1, 3, 2 do
    bprint(sub(enemy_time, i, i + 1), 100 + i * 6, 6, 7, 0)
  end
  bprint(".", 114, 6, 7, 0)
  bprint(enemy_name, 2, 6, 7, 0)
  for i = 1, enemy_lives do
    bprint("★", 2 + (i - 1) * 10, 14, 7, 0)
  end
  -- player
  for i = 1, player_livesmax do
    bprint("♥", 119 - (i - 1) * 9, 14, 5, 0)
  end
  for i = 1, player_lives do
    bprint("♥", 119 - (i - 1) * 9, 14, 7, 0)
  end
  for i = 1, 3 do
    bprint("\134", 119 - (i - 1) * 9, 22, 5, 0)
  end
  for i = 1, player_bomb do
    bprint("\134", 119 - (i - 1) * 9, 22, 7, 0)
  end
end

function ui_draw()
  if level_index() >= 16 then
    ui_draw_title()
  else
    ui_draw_level()
  end
end

function ui_sudodraw()
  if paused then
    draw_char_title(47)
  end
  if player_hit then
    draw_dialog("try again", 47)
  end
  if player_dead then
    draw_dialog("game over", 47)
  end
end

frame = 0
mode = 2
-- 0 practice 1 easy 2 normal 3 hard 4 lunatic
paused = false
score = 0

function _init()
  cartdata("chronodave_touhou_unmei_no_hoshi")
  score_init()
  level_set(0, 2, 1)
end

function _update60()
  frame = ((frame + 1) % 120)
  level_update()
  ui_update()
  if level_index() < 16 then
    if not player_hit and not player_dead and not enemy_dead and not paused then
      player_collision()
      player_input()
      bullets_player()
      enemy_update()
      enemy_move()
      enemy_shoot()
      bullets_enemy()
      if enemy_lives < 0 then
        enemy_dead = true
      end
    end
    if enemy_dead then
      enemy_dead = false
      if mode == 0 then
        ui_page = 1
        level_set(0, 2, 1)
      else
        player_reset()
        if player_bomb < 3 then
          player_bomb += 1
        end
        if level_index() + 1 >= 4 then
          ui_page = 7
          ui_score_name = ""
          level_set(0, 2, 1)
        else
          level_set(level_index() + 1, 0, audio_track + 1)
          enemy_create(level_index() + 1)
        end
      end
    end
  end
end

function _draw()
  cls()
  palt(3, true)
  palt(0, false)
  level_draw()
  ui_draw()
  if level_index() < 16 then
    if data_spellcard[enemy_b] then
      bprint(data_spellcard[enemy_b], 2, 121, 7, 0)
    end
    enemy_drawmarker()
    player_draw()
    enemy_draw()
    ui_sudodraw()
  end
end


__gfx__
38383333333113333333333333333337333333333338833333333333333333333333331113333333333333333333333333333333333333333333333333333333
80803358337117333333333333333337333333333883333333333333333333333333331f1333333333333333333333333333333333333dddd3d3333333333333
30003357311771133333333333333377333383338333333333333333333333331111111f111111131331111111111133333333333333dddd3333333333333333
70873537331111333338833333333377333333383333333333333333333333331fffffffffffff111131fffffffff1333333333333ddddd33333333333333333
76b7f53733ab6a333338833333333757333383833333333333333333338333331111111f1111111ff111f1111111f13333333333ddddddd33333333333333333
3887333333611633333333333333375733338383333333333333333333383333331fffffffff13111f11fffffffff1333333333ddddddddd3333333333333333
8888333331111113333333333333756733338883333333333333333333383333331f111f111f133311f1f1111111f1333333333ddddddddddddd333333333333
33f3333333144133333333333333756738383883333333333333333333383833331fffffffff133331f1fffffffff13333333333dddddddddddddd3333333333
3333333333333333333333333337566733883883333333333333333333383833331f111f111f133331f11f11f11111333333333ddddddddddddddd3333333333
3333333333333333333333333337566733888983333333333333333333888883331fffffffff133311f11f11f11111133333333dddddddddddddd33333333333
3888888333c33c33333883333375666733888883333333333333333333883883331111fff11113331f11ffffffffff13333333ddddddddddddddd33333333333
387877833c7cc7c333877833337566678388888833389833333333333898388333111f1f1f1113331f1f1111f1111113333333ddddddddddddddd333333d3333
387787833c7cc7c3338778333756666738398888333339883333333388888833111ff11f11ff1113f1111fffffff1333333333ddddddddddddddd3333333d333
3888888333c33c333338833337566667338888998333389833333388888888331ff1111f1111ff1111111111f111111133333dddddddddddddddd33333d3d3d3
33333333333333333333333375666667838888999333388883333898888983831111331f1331111131fffffffffffff133333ddddddddddddddd33333ddd3d33
3333333333333333333333337777777783888899993338888338999988888833333333111333333131111111111111113333dddddddddddddddd33d33dd3d333
333333333333333333333333333333a338388899999389833899999988888833333311133333333333333333333333333333ddddddddddddddd3333dddddd333
3333c3333338383333388333393883333883889999999983899999998888833333331f133333111133333333333333333333dddddddddddddddd3333ddd33333
3333c3333388388333877833388998333888388999999983999999988888833333331f1333331f113333333333333333333ddddddddddddddddd333ddddd3333
333ccc3333333333387777838a98a9833838833999999998899999988838833311111f11111111f1333333333333333333dddddddddddddddddd3333ddd33333
333ccc3333883883387777833898898338888888999999988998898838883333ffffffffffff11ff33333333333333333dddddddddddddddddddd333333d3333
3333c333333838333387783333899833338388888898999889998888898833331111f1111111111133333333333333333dddddddddddddddddddd33dddd33333
3333333333333333333883333938aa83333888888888998889998888883333333331f1111111111133333333333333333dddd3ddddddddddddddddddd33333dd
33333333333333333333333333338833338333889888998888998888388333333331ffffff11fff13333333333333333dddd3dddddddddddddd3dddddddddd33
33333333333333333388883333833333333883338888888988988888883333333331f1111f1111f13333ddd33dddddddddddddddddddddd3333333d333333333
33333333333333333877778338338383333388888333888988988888833333333311f1331f1331f1333dddd33ddddddddddddddddddddddddddd333333333333
3333333333333333877777783333883333333883888388988888988833333333331f11331f1331f1333dddd3dddddddddddddddd3dddddddd333333333333333
3333333333333333877777783338a83333333338388888988888883333333333311f13331f1331f1333ddd33dddddddddddddddd33dddddddd33333333333333
3333333333333333877777783389a8833333333333883898888833333333333311f113331f1311f1333ddd33ddddddddddddddddd3ddddddddd3333333333333
333333333333333387777778389aa983333333333338838888333333333333331f1131111f111f1f33dddddddddddddddddddddddd3dddddddddddddd3333333
333333333333333338777783388a983333333333333338883333333333333333f11331fff111f11133dddddddd3dddddddddddddddd3ddddd3dddddddd333333
3333333333333333338888333388833333333333333333383333333333333333113331111131113333dddddddd3ddddddddddddddddddddddd3ddddddd333333
cccccbbbbbbcccccccccc777777accccccc87cccccc78ccccc822777777ccccc333333333333333133ddddddd33ddddddddddddddddddddddd3333dddddd3333
cccc33333333cccccccc78777777acccccc8786666878cccc82787777777cccc111111111133331133ddddddd33ddddddddddddddddddddddd3333333ddd3333
cccb333aa333bcccccc787777a7aaccccccc87877878ccccc272877777777cccfffffffff133311f33dddddddd3dddddddddddddddddddddddd333333dddd333
ccb3322aa2233bcccc77766776aa77cccccc88666688ccccc2882667766777ccf111f11f113111f133dddddddddddddddddddddddddddddddddd333333ddd333
cc332888888233cccc776226622677cccccc66666666cccccc776dd66dd677ccfffffffff111ff1133dddddddddddddddddddddddddddddddddddd3333ddd333
cc32800f008823ccc1762222222267ecccc6600600666cccc076d00d00dd670c1111f11111ff1fff33dd3ddddddddddddddddddddddddddddddddd3333ddd333
ccc2871ff1082ccccc16200f00222eccccc6678ff8066ccc0556d78ff80d65501fffffff111111113dd3ddddddddddddddddddddddddddddddddddd3dddd3333
cccc871ff1788cccccc227dffd022cccccca878ff8766ccc050dd78ff87dd0501f11f11f131ffff13d333ddddddddddddddddddddddddddddddddddddddd3333
cccc28ffff888ccccc0050ffff222ccccc8a98ffff66cccc0505ddffffdd50501fffffff131f11f1dd33dd33dddddddddddddddddddddddddddddddddddd3333
cccc82700782cccccc005078872ecccccc99a8877866cccc05050878878050501f11f11f131f11f1dd33dd3dddddddddddddddddddddddddddddddddddddd333
ccccff3733288ccccc00508778e22cccccc887877876cccc0505ff8778ff50501fffffff131f11f13d33dd33dddddddddddddddddddddddddddddd3ddddddd33
ccccff3733ff8ccccc0ff0677ff72ccccccff62227ffcccc0550ff6776ff05501111f111111ffff13d33dd33ddddddddddddddddddddddddd3ddddd33dddddd3
cccccc7777ff88cccccc77677ff7ccccccc6628222f66ccc05cc67766776cc50fffffffff11f11f133d3ddd3ddddddddddddddddddddddddd3ddddd3333dddd3
ccccc3f733333cccccc7776776777cccccc6682282266cccc0c8777777778c0cf111f111111f11113333ddd33dddddddddddddddddddddddd3dddddd333dddd3
cccc3ff7333333ccccc6776776776ccccccc62211826ccccccc6786776876ccc1ffffffff11113333333dddd3dddddddddddddddddddddddd3dddd333333dddd
cccccffc7333cccccccc66666666ccccccccc44cc44ccccccccc66666666cccc111111111133333333333dddd3dddddddddddddddddddddd33dddd33dd33dddd
3333333333333333333333333333333333333333333333333333333333333333113333333333333333333dddd3ddddddddddddddddddddddddddddddddd33ddd
3338833333399333333aa333333bb333333cc333333ee3333335533333333333f113333333333333333333dddd3dddddddddddddddddddddddddddddddd3dddd
338778333397793333a77a3333b77b3333c77c3333e77e3333566533333333331f113333333111113333333ddddddddddddddddddddddddddddd33ddddd3ddd3
38777783397777933a7777a33b7777b33c7777c33e7777e3356776533333333311f111333111ffff3333333dddddd3ddddddddddd33dddd33ddd333ddddddd33
38777783397777933a7777a33b7777b33c7777c33e7777e33567765333333333111ff11111ff1f11333333dddddddd333dd33dd333dddddd33dddddddd3d3333
338778333397793333a77a3333b77b3333c77c3333e77e333356653333333333ffff1ff11f111f11333333dddddddd3333333dd333dddddddddddddd33ddd333
3338833333399333333aa333333bb333333cc333333ee3333335533333333333111111111f111f133333333dddddddd333333dd333dddddd33ddddd333dddd33
33333333333333333333333333333333333333333333333333333333333333331fffff11f111f113333333333dd33ddd3333333333333333333ddd3333dddd33
33777733333333333333333333333333333333333333333333555533333333331f111f11f111f1333333333333333ddddd33333333333333333ddd3333ddd333
37888873333333333333333333333333333333333333333335677653333333331f131f11f11f1133333333333333333dddd333333333d33333dddd3333333333
78822887333333333333333333333333333333333333333356777765333333331f131f11f11f133333333333333333d33ddd3333d33dddd333ddd33333333333
78222287333333333333333333333333333333333333333357777775333333331f111f11f1f1131133333333333333d3333d3333ddd3ddddddddd33333333333
78222287333333333333333333333333333333333333333357777775333333331ffff1111f11111f333333333333333d3333d333ddddddddddddddd333333333
78822887333333333333333333333333333333333333333356777765333333331f11113311131ff133333333333333333333d3333dddddddddddddd333333333
37888873333333333333333333333333333333333333333335677653333333331f1333333333311133333333333333333333333333333333333ddd3333333333
33777733333333333333333333333333333333333333333333555533333333331113333333333333333333333333333333333333333333333333d33333333333
77777776999999999999999999999999999999999999999422222222222222222222222282822222222228288288222233333333333333334443443334444444
7767766d999999999999999999999999999999999999999422822222222228222222222288822222222228888288822233333333333333333333444344433344
7766666d999999999999999999999999999999999999999428882282282288822222222288822222222228888282882233333333333333333333344444333434
766676ddfff9fffff9ff9999fff9fffff9ff99999999999428888288882888828888888888882222222288888288888833333333333333333333334443334334
776666ddfff9fffff9fff999fff9fffff9fff9999999999482888828828888288888888888888222222888888288888833333333333333333333333444443334
7667666d9994999994999444fff9fffff9ffff994444444422228888888822222222222288288822228882888282882233333333333333333333333344443344
7666d6dd9994999994999944fff9fffff9ffff994444444422222228822222222222222282288882288882288288822233333333333333333333333334443444
6dddddddfff9fffff9ffff99fff9fffff9ffff999999999422222222222222222222222282288888888882288288222233333333333333333333333333444443
6666666d999999999999999999999999999999994999999922222282282222222228822282822288882228282222882833333333333333333333333333344433
66d66dd59999999999999999fff9fffff9ffff994999999922222288882222222288882288222888888222882228882833333333333333333333333333334443
66ddddd59999999999999999fff9fffff9ffff994999999922228828828822222882288282228882288822282288282833333333333333333333333333333444
6ddd6d559999ff9fffff9ffffff9fffff9ffff994999999982888888888888288888888888888822228888888888882833333333333333333333333333333344
66dddd55999fff9fffff9ffffff9fffff9fff9994999999928888228822888828888888888888822228888888888882833333333333333333333333333333333
6dd6ddd54449994999994999fff9fffff9ff99994444444428882222222288822882288282228882288822282288282833333333333333333333333333333334
6ddd5d55449999499999499999999999999999994444444422822222222228222288882288222888888222882228882833333333333333333333333333333334
d555555599ffff9fffff9fff99999999999999994999999922222222222222222228822282822288882228282222882833333333333333333333333333333334
ddddddd1999999999999999999999999999999999999999982822222888888888882222282288888888882288888888833333333333333333333333333333333
dd5dd551999999999999999999999999999999999999999982822222822222228282822282288882288882282222222233333333333333333333333333333333
dd555551999999999999999999999999999999999999999982822222828888888882822288288822228882888888888833333333333333333333333333333333
d555d5119999ff9fffff9fff99999999999999999999999982822222828228822228222288888222222888882222222233333333333333333333333333333333
dd555511999fff9fffff9fff99999999999999999999999982822222828288222882222288882222222288882222222233333333333333333333333333333333
d55d555199ffff9fffff9fff44444444999999999999999982822222828882222222222288822222222228882222222233333333333333333333333333333333
d555151199ffff9fffff9fff44444444999999944999999982822222828822222222222288822222222228882222222233333333333333333333333333333333
1111111199ffff9fffff9fff99999999999999944999999982822222828222222222222282822222222228282222222233333333333333333333333333333333
55555550999999999999999999999994499999993333333322222828888888882222288888888888888888888888888833333333333333333333333333333333
5515511099ffff9fffff9fff99999994499999993333333322222828222222282228282828888822282882822288888233333333333333333333333333333333
5511111099ffff9fffff9fff99999994499999993333333322222828888888282228288888888222822882282228888833333333333333333333333333333333
5111510099ffff9fffff9fff99999994499999993333333322222828288228282222822222288888222882228888822233333333333333333333333333333333
55111100999fff9fffff9fff99999994499999993333333322222828228828282222288222228888228888228888222233333333333333333333333333333333
511511109999ff9fffff9fff99999994499999993333333322222828222888282222222222222888288888828882222233333333333333333333333333333333
51110100999999999999999999999994499999993333333322222828222288282222222222222288888228888822222233333333333333333333333333333333
00000000999999999999999999999994499999993333333322222828222228282222222222222228882222888222222233333333333333333333333333333333
565555555555555507666776677600008e828822288288880660000679a99aa967d6666666666666dd22dd112e7e22e733333333333333333333333333333333
5566605555555555666999999997666088e2e2222282882800112100669aaa976d76776666666666dddddddd1222112733333333333333333333333333333333
5555505666566660999aaaaaaa9997668282824442e8ee28221ee122111999666d6d66d777d777d6d6ddddddddddd11233333333333333333333333333333333
50555005550555554a99aa77a77a99998282824ff2828828221221eee1eee010d56d66d666d666d6ddd66dddddddddd133333333333333333333333333333333
00505000550055554a94aaaa9aaaa9a9228242fff28288281212212221222122556d66d666d666d6ddd1dd1d66ddd66d33333333333333333333333333333333
00500040050005554a99aa9aa4aaaa9a228224fff2222228000111222122212205d555d666d666d61dd11141dd1ddddd33333333333333333333333333333333
000000f4000000000aa99949a99aa94902224fffff4444280104444000000000b0d54444554555550dd144f41dd111dd33333333333333333333333333333333
b008000f4000000009a400049a0000040222000fff00000201000ff444444011b0d5000f4400000db0d1000f4100000d33333333333333333333333333333333
bb08fffff4ffff820494ffff49ffff49b022ffffffffff22010ffffff0000022b025ffffffffff56b011fffff4ffff1d33333333333333333333333333333333
bb08ffffffffff82b044fffff4ffff4abb02ffffffffff28110ffffffffff022b0d5ffffffffffd600d1ffffffffff1d33333333333333333333333333333333
bb064fffffffff82b094ffffffffff4abb024fffffffff222114fffffffff122b0d54fffffffff6650d14fffffffff1d33333333333333333333333333333333
bb0504fffffff467b0a44ffffffff44abb0204fffffff42822104fffffff41eebb0d04fffffff46d601114fffffff41d33333333333333333333333333333333
bbb0504444444055b090444444444449bb565044444440221211044444441222bb025044444445d560101044444441dd33333333333333333333333333333333
bbbb0469666244500900406766007649bb02037700776356011c112e76682211bb05026767627000050506878876780133333333333333333333333333333333
bbb0609a9882276000b0600000006704bbb0300576503702b001c18766128211bbb0607677802805065080677760270033333333333333333333333333333333
bbb060aaa8822676bbb0f07776660f40bbb0f03373360ff0bb01017676122800bbb06076778606700060f02888220ff033333333333333333333333333333333
565555555555555507666776677600008e828822288288880660000679a99aa967d6666666666666dd22dd112e7e22e733333333333333333333333333333333
5566605555555555666999999997666088e2e2222282882800112100669aaa976d76776666666666dddddddd1222112733333333333333333333333333333333
5555505666566660999aaaaaaa9997668282824442e8ee28221ee122111999666d6d66d777d777d6d6ddddddddddd11233333333333333333333333333333333
50555005550555554a99aa77a77a99998282824ff2828828221221eee1eee010d56d66d666d666d6ddd66dddddddddd133333333333333333333333333333333
00505000550055554a94aaaa9aaaa9a9228242fff28288281212212221222122556d66d666d666d6ddd1dd1d66ddd66d33333333333333333333333333333333
00500040050005554a99009aa49aa99a228200fff2222228000111222122212205d500d666d666d61dd10041dd1ddddd33333333333333333333333333333333
000060f4000000000aa96049a9000049022260fff40000280104444000000000b0d56044550000550dd160f41d0000dd33333333333333333333333333333333
b00864ff4040060009a464f49a400604022261ffff40060201000ff444444011b0d562ff4440060db0d162ff4140060d33333333333333333333333333333333
bb0879fff4f47782049479ff49f47749b0227cfffff1772201062ffff0000022b02578fffff27756b01178fff4f2771d33333333333333333333333333333333
bb08f4fffff94782b044f4fff4f9474abb02f1fffffc17281107efffff216022b0d5f2fffff827d600d1f2fffff8271d33333333333333333333333333333333
bb064ffffff44f82b094fffffff44f4abb024ffffff11f222114ffffffe27122b0d54ffffff22f6650d14ffffff22f1d33333333333333333333333333333333
bb0504fffffff467b0a44ffffffff44abb0204fffffff42822104fffffff41eebb0d04fffffff46d601114fffffff41d33333333333333333333333333333333
bbb0504444444055b090444444444449bb565044444440221211044444441222bb025044444445d560101044444441dd33333333333333333333333333333333
bbbb0469666244500900406766007649bb02037700776356011c112e76682211bb05026767627000050506878876780133333333333333333333333333333333
bbb0609a9882276000b0600000006704bbb0300576503702b001c18766128211bbb0607677802805065080677760270033333333333333333333333333333333
bbb060aaa8822676bbb0f07776660f40bbb0f03373360ff0bb01017676122800bbb06076778606700060f02888220ff033333333333333333333333333333333
__map__
8080b400000000000000000000b38080a09000000000000000000000000090a0a0a08b888888888687888888889ba0a0a09089000000000000000000008a90a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8080958182a300000000a39192858080a09000000000000000000000000090a0a0a0a600000000000000000000b6a0a0a09099000000000000000000009a90a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8080b49394000000000000b1b2b38080a09000000000000000000000000090a0a0a0a600000000000000000000b6a0a0a090a900000000000000000000aa90a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8080b400000000a4a500000000b38080a09000000000000000000000000090a0a0a0a600000000000000000000b6a0a0a090a600000000000000000000b690a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8080b483840000b3b40000a1a2b38080a0a0000000000000000000000000a0a0a0a0a600000000000000000000b6a0a0a0a0a600000000000000000000b6a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8080b493940000b3b40000b1b2b38080b0a0000000000000000000000000a0b0a0a0a600000000000000000000b6a0a0a0a0a600000000000000000000b6a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8080b400000000b3b400000000b38080b0a0000000000000000000000000a0b0a0a0a600000000000000000000b6a0a0a0a0a600000000000000000000b6a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8080b400000000b3b400000000b38080b0b0000000000000000000000000b0b0a0a0a600000000000000000000b6a0a0a0a0a600000000000000000000b6a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8080b400000000b3b400000000b38080b0b0000000000000000000000000b0b0a0a08b888888889697888888889ba0a0a0a08b889888888888888898889ba0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8080b400000000b3b400000000b38080b0b0000000000000000000000000b0b0a0a0a600000000000000000000b6a0a0a0a0a600000000000000000000b6a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8080b400000000b3b400000000b38080b0b0000000000000000000000000b0b0a0a0a600000000000000000000b6a0a0a0a0a600000000000000000000b6a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8080b400000000b3b400000000b38080b0b0000000000000000000000000b0b0a0a0a600000000000000000000b6a0a0a0a0a600000000000000000000b6a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8080b400000000b3b400000000b38080b0b0000000000000000000000000b0b0a0a0a600000000000000000000b6a0a0a0a0a600000000000000000000b6a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8080b400000000b3b400000000b38080b0a0000000000000000000000000a0b0a0a0a600000000000000000000b6a0a0a0a0a600000000000000000000b6a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8080b483840000b3b40000a1a2b38080b0a0000000000000000000000000a0b0a0a0a600000000000000000000b6a0a0a0a0a600000000000000000000b6a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8080b493940000b3b40000b1b2b38080a0a0000000000000000000000000a0a0a0a0a600000000000000000000b6a0a0a090a600000000000000000000b690a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00001b3130000024615000000c0430000024615000001b3130000024615000000c0430000024615000001b3130000024615000000c0430000024615000001b3130000024615000000c043000002461500000
010c00200c043000001b313000000c043000001b313000000c043000001b313000000c043000001b313000000c043000001b313000000c043000001b313000000c043000001b313000000c043000001b31300000
010c00200c0430c04330615000000c0430000030615000000c0430c043306151b3130c04300000306151b3130c0430c04330615000000c0430000030615000000c0430c043306151b3130c04300000306151b313
010c00201b3130c0431b3130c0430c0430000030615000001b313000000c04300000306150c04330615306151b3130c0431b3130c0430c0430000030615000001b313000000c04300000306150c0433061530615
010c00200c0430c0430c04300000306153061530615000001b313000000c043000000c043000000c043000001b3130c0430c0430c043306153061530615000001b313000000c043000000c043000000c04300000
010c00000c0430c04330615000001b3130000000000000000c0430c04330615000001b3130000000000000000c0430c04330615000001b3130000030615000000c0430c04330615306151b31300000306151b313
010c00001b3130000030615000000c0430000030615000001b3130000030615000000c0430000030615000001b3130000030615000000c0430000030615000001b3130000030615000000c043000003061500000
010c00002461024615246150c0430c0430000000000000001b3230000000000000000c0430000000000000001b3230000000000000000c0430000000000000001b3230000000000000000c043000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01030000183432433730323303003c300003000030100301003010030100301003010030100301003010030100301003010030100301003010030100301003010030000300003000030000300003000030000300
0108000030730183513c6533064124231186210c2110c6150c6000c6000c6000c6000c6000c6000c6000c60500003000030000300003000030000300003000030000300003000030000300003000030000300003
010300002455518555203360e326247500c73500000000000c0000c0000c6000c6000c6000c6000c6000c6003c0553c51530055305142405424514180540c5140c51418054245142405430515300553c5153c055
__label__
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111dddd1d111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111111111dddd111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111ddddd1111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111111111ddddddd1111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111ddddddddd111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111ddddddddddddd11111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111111111dddddddddddddd111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111ddddddddddddddd111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111dddddddddddddd1111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111ddddddddddddddd1111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111f1111111111111f11111d11111111111111111111f111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111f1111111111111f11111d1f11fffffffff111111f1f11111111111111111111111111111111111111111111111111111
11111111111111111111111111fffffffffffff1111111f11111111f1f111f11f111111f111f111111111ffff1111fffffffff11111111111111111111111111
11111111111111111111111111111111f1111111fffffffffffff11fffffffffff111ff11111ff11111ff1f11f111f1111111f11111111111111111111111111
1111111111111111111111111111fffffffff11111111f111111111111111f11111ff1fffffff1ff11f111f111f11fffffffff11111111111111111111111111
1111111111111111111111111111f111f111f11111111f111111111111fffffff11111111111111111f111f1111f1f1111111f11111111111111111111111111
1111111111111111111111111111fffffffff11111111ffffff11fff11f11f11f111ffff11fffff11f111f11111f1fffffffff11111111111111111111111111
1111111111111111111111111111f111f111f11111111f1111f1111f11fffffff111f11f11f111f11f111f11111f11f11f111111111111111111111111111111
1111111111111111111111111111fffffffff11111111f11d1f1dd1f11f11f11f111f11f11f111f11f11f111111f11f11f111111111111111111111111111111
1111111111111111111111111111111fff1111111111f11dd1f1dd1f11fffffff1d1f11f11f111f11f11f11111f11ffffffffff1111111111111111111111111
111111111111111111111111111111f1f1f111111111f11dd1f1dd1f11111f111111ffff11f111f11f1f111111f1f1111f111111111111111111111111111111
1111111111111111111111111111ff11f11ff111111f111dd1f1d11f1fffffffff11f11f11ffff1111f11111ff1111fffffff111111111111111111111111111
11111111111111111111111111ff1111f1111ff111f1111111f111f1ff111f111111f11111f11111111111ff111111111f111111111111111111111111111111
11111111111111111111111111111111f11111111f11111fff111f1111ffffffff1111ddd1f11111d1111111111fffffffffffff111111111111111111111111
111111111111111111111111111111111111111111111d11111d111dd1111111111dddddd111dd11111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111dddd1dddddddddddddddd1dddddddd11111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111ddd1111d1111ddd111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111f1f1ff11fff1fff1fff1ddd1ff111ff1ddd1f1f11ff11ff1f1f1fff1111111111111111111111111111111111111
211121112111211121112111211111f12111f1f1f1f1fff1f1111f11ddd1f1f1f1f12dd1f1f1f1f1f111f1f11f11211111f12111211121112111211121112111
1111111111111111111111111111fff11111f1f1f1f1f1f1ff1d1f1dddd1f1f1f1f1d1d1fff1f1f1fff1fff11f111111fff11111111111111111111111111111
1111111111111111111111111111f1111111f1f1f1f1f1f1f1111f11ddd1f1f1f1f1ddd1f1f1f1f111f1f1f11f111111f1111111111111111111111111111111
1111111111111111111111111111111111111ff1f1f1f1f1fff1fff1ddd1f1f1ff11ddd1f1f1ff11ff11f1f1fff1111111111111111111111111111111111111
21112111211121112111211121112111211111111111111111111111ddd11111111dddd111111111111111111111211121112111211121112111211121112111
11111111111111111111111111111111111111111111dddddddd1dddddddddddddddddddddddd111111111111111111111111111111111111111111111111111
11211121112111211121112111211121112111211121dddddddddddddddddddddddddddddddddd21112111211121112111211121112111211121112111211121
11111111111111111111111111111111111111111111dddddddddddddddddddddddddddddddddddd111111111111111111111111111111111111111111111111
21212121212121212121212121212121212121212121dd2ddddddddddddddddddddddddddddddddd212121212121212121212121212121212121212121212121
1111111111111111111111111111111111111111111dd1ddddddddddddddddddddddddddddddddddd11111111111111111111111111111111111111111111111
1121112111211121112111211121112111211121112d112ddddddddddddddddddddddddddddddddddd2111211121112111211121112111211121112111211121
111111111111111111111111111111111111111111dd11dd11dddddddddddddddddddddddddddddddd1111111111111111111111111111111111111111111111
21212121212121212121212121212121211fffff11dd21dd2ddddd11111111111111111111dddddddd21211fffff112121212121212121212121212121212121
1111111111111111111111111111111111ff1f1ff11d11dd11ddd11ff1fff1fff1fff1fff1dddddd1d1111ff1f1ff11111111111111111111111111111111111
2121212121212121212121212121212121fff1fff12d21dd21ddd1f1111f11f1f1f1f11f11d1ddddd12121fff1fff12121212121212121212121212121212121
1111111111111111111111111111111111ff1f1ff111d1ddd1ddd1fff11f11fff1ff111f1dd1ddddd11111ff1f1ff11111111111111111111111111111111111
21212121212121212121212121212121211fffff112121ddd12dd111f11f11f1f1f1f11f1dd1dddddd21211fffff112121212121212121212121212121212121
1111111111111111111111111111111111111111111111dddd1dd1ff111f11f1f1f1f11f1dd1dddd111111111111111111111111111111111111111111111111
21212121212121212121212121212121211111111121212dddd1d1111d111111111111111d21dddd212121111111112121212121212121212121212121212121
11111111111111111111111111111111111111111111111dddd1dddddddddddddddddddddddddddddd1111111111111111111111111111111111111111111111
21212121212121212121212121212121212121212121212111111111111111111111111111111111dd2121212121212121212121212121212121212121212121
121112111211121112111211121112111211121112111211ddd1ddd1ddd11dd1ddd1ddd11dd1ddd1dd1112111211121112111211121112111211121112111211
212121212121212121212121212121212121212121212121d1d1d1d1d1d1d1111d111d11d111d1112d2121212121212121212121212121212121212121212121
111211121112111211121112111211121112111211121111ddd1dd11ddd1d11d1d121d11d111dd1ddd1211121112111211121112111211121112111211121112
212121212121212121212121212121212121212121212121d111d1d1d1d1d1111d111d11d111d111dd2121212121212121212121212121212121212121212121
121112111211121112111211121112111211121112111211d1d1d1d1d1d11dd11d11ddd11dd1ddd1d21112111211121112111211121112111211121112111211
21212121212121212121212121212121212121212121212111211111111111111111111111111111212121212121212121212121212121212121212121212121
1112111211121112111211121112111211121112111211121112111ddddd11121112111211121ddd111211121112111211121112111211121112111211121112
212121212121212121212121212121212121212121211111111111111111d1211111111111111111111121212121212121212121212121212121212121212121
12121212121212121212121212121212121212121211d1d1ddd11dd1d1d1dd111dd11dd11dd1ddd1ddd112121212121212121212121212121212121212121212
21212121212121212121212121212121212121212121d1d11d11d111d1d12d21d111d111d1d1d1d1d11121212121212121212121212121212121212121212121
11121112111211121112111211121112111211121111ddd11d11d111ddd111d1ddd1d1d1d1d1dd11dd1211121112111211121112111211121112111211121112
21212121212121212121212121212121212121212121d1d11d11d1d1d1d121d111d1d111d1d1d1d1d11121212121212121212121212121212121212121212121
12121212121212121212121212121212121212121211d1d1ddd1ddd1d1d11211dd111dd1dd11d1d1ddd112121212121212121212121212121212121212121212
21212121212121212121212121212121212121212121111111111111111121211111111111111111111121212121212121212121212121212121212121212121
12121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212
21212121212121212121212121212121212121212121111111111111111111112121111111111111111121212121212121212121212121212121212121212121
12121212121212121212121212121212121212121211ddd1d1d11dd1ddd11dd11211ddd11dd11dd1ddd112121212121212121212121212121212121212121212
21212121212121212121212121212121212121212121ddd1d1d1d1111d11d1112121d1d1d1d1d1d1ddd121212121212121212121212121212121212121212121
12121212121212121212121212121212121212121211d1d1d1d1ddd11d11d1121211dd11d1d1d1d1d1d112121212121212121212121212121212121212121212
22212221222122212221222122212221222122212221d1d1d1d111d11d11d1112221d1d1d1d1d1d1d1d122212221222122212221222122212221222122212221
12121212121212121212121212121212121212121211d1d11dd1dd11ddd11dd11211d1d1dd11dd11d1d112121212121212121212121212121212121212121212
21212121212121212121212121212121212121212121111111111111111111112121111111111111111121212121212121212121212121212121212121212121
12121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212
22212221222122212221222122212221222122212221222122111111111111111111111112111121222122212221222122212221222122212221222122212221
121212121212121212121212121212121212121212121212111dd1ddd1ddd1ddd11dd1dd111dd112121212121212121212121212121212121212121212121212
21222122212221222122212221222122212221222122212221d1d1d1d11d111d11d1d1d1d1d11122212221222122212221222122212221222122212221222122
12121212121212121212121212121212121212121212121211d1d1ddd11d121d11d1d1d1d1ddd112121212121212121212121212121212121212121212121212
22222222222222222222222222222222222222222222222221d1d1d1111d111d11d1d1d1d111d122222222222222222222222222222222222222222222222222
12121212121212121212121212121212121212121212121211dd11d1121d11ddd1dd11d1d1dd1112121212121212121212121212121212121212121212121212
21222122212221222122212221222122212221222122212221111111211111111111111111111122212221222122212221222122212221222122212221222122
12121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
12121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
12121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
12121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
12121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22122212221222122212221222122212221222122212221222122212221222122212221222122212221222122212221222122212221222122212221222122212
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
12221222122212221222122212111111111111111122111111111122121112111111111111111111121111111111111111111122122212221222122212221222
222222222222222222222222211ff1fff1fff1fff12221fff1f1f111111f111ff1f1f1fff11ff1ff111ff1ff11fff1f1f1fff122222222222222222222222222
22122212221222122212221221f111f1f1fff1f1111221f1f1f1f11f11f1f1f111f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f11112221222122212221222122212
22222222222222222222222221f111fff1f1f1ff122221ff11fff11111f1f1f121fff1ff11f1f1f1f1f1f1f1f1fff1f1f1ff1222222222222222222222222222
12221222122212221222122211f1f1f1f1f1f1f1112211f1f111f11f11f111f111f1f1f1f1f1f1f1f1f1f1f1f1f1f1fff1f11122122212221222122212221222
22222222222222222222222221fff1f1f1f1f1fff12221fff1fff111111ff11ff1f1f1f1f1ff11f1f1ff11fff1f1f11f11fff122222222222222222222222222
22222222222222222222222221111111111111111122211111111122221111111111111111111111111111111111111111111122222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
__meta:title__
touhou unmei no hoshi
by chronocide
