# วิจัยเกมและตัวเลือก Assets สำหรับ Blink Arcana

## ขอบเขตและวิธีอ่านเอกสาร

เอกสารนี้สังเคราะห์ **เฉพาะข้อมูลและ URL ในผลค้นคว้าที่ให้มา** เพื่อใช้เป็นแนวทางออกแบบและคัดเลือกทรัพยากรสำหรับ Blink Arcana ไม่ใช่การตรวจสอบซอร์สโค้ดหรือการรับรองความเข้ากันได้ทางเทคนิคของเกม/asset ใด ๆ

- **ไม่ได้ติดตั้ง ดาวน์โหลด หรือทดลองใช้งาน asset ใด** ในการจัดทำเอกสารนี้ ลิงก์ดาวน์โหลดที่แสดงมีไว้เพื่ออ้างอิงและตรวจสอบใบอนุญาตเท่านั้น
- บทเรียนจากเกมเป็น **หลักการที่สกัดเพื่อนำไปทดลอง** ไม่ใช่คำยืนยันว่าควรคัดลอกระบบ ภาพ ตัวละคร หรือองค์ประกอบเฉพาะของ IP
- คำว่า **“ยืนยัน Godot”** ใช้เฉพาะกรณีที่ผลค้นคว้ามีหลักฐานจากแหล่งที่ระบุโดยตรงเท่านั้น ไม่อนุมานจากรูปลักษณ์เกม ภาษาโปรแกรม หรือข่าวลือ

## สรุปสำหรับการตัดสินใจ

1. สำหรับแกน **tactical grid RPG** ให้เริ่มจากบทเรียนของ **Into the Breach, The Last Spell และ Battle Brothers** โดยเน้นการอ่านเจตนาศัตรู ต้นทุนของตำแหน่ง/ทรัพยากร ความหลากหลายจากข้อดีข้อเสีย และระบบที่ทำให้แต่ละศัตรูบังคับการตอบสนองต่างกัน
2. เกมที่ผลค้นคว้า **ยืนยันว่าใช้ Godot** คือ **Dome Keeper** และ **Brotato** แต่ทั้งคู่ไม่ใช่ tactical grid RPG: Dome Keeper เป็น survival miner แบบแอ็กชันมุมมองด้านข้าง ส่วน Brotato เป็น top-down arena shooter แบบเรียลไทม์ จึงควรหยิบเฉพาะหลักการเรื่องลูป จังหวะ การคุมขอบเขต และ build ไม่ใช่คัดลอกจังหวะการเล่นโดยตรง
3. หากต้องการลดภาระด้านใบอนุญาตในต้นแบบ **Kenney Roguelike/RPG pack, Tiny Dungeon, UI Pack และ RPG Audio** เป็นตัวเลือก CC0 ตามแหล่งที่ให้มา โดยยังต้องระวังเครื่องหมายการค้า โลโก้ การสื่อว่าเจ้าของรับรองเกม และสิทธิของบุคคลอื่น
4. หากต้องการ tileset 16×16 ที่ระบุแนว turn-based strategy/RPG อย่างชัดเจน **Toen’s Medieval Strategy Sprite Pack** เหมาะเป็นตัวเลือก CC BY 4.0 แต่ต้องทำ attribution และเก็บข้อมูลใบอนุญาตไว้กับโปรเจกต์

---

# 1) เกมเปรียบเทียบและบทเรียนที่ทำได้จริง

## 1.1 แกน tactical design: เกมที่ใช้เป็นกรณีศึกษาเชิงการออกแบบ

### Into the Breach

**ลักษณะและความเกี่ยวข้อง**

- เป็นเกมวางแผนกลยุทธ์แบบผลัดตา แนว tactical mech combat มีความท้าทายแบบสุ่มและการส่งนักบิน/ความช่วยเหลือข้ามไทม์ไลน์เมื่อแพ้ จึงมีองค์ประกอบ roguelite แต่แหล่งข้อมูลเรียกเกมหลักว่า turn-based strategy ไม่ใช่ tactical grid RPG เต็มรูปแบบ ([1](https://subsetgames.com/itb.html), [2](https://www.gamedeveloper.com/game-platforms/road-to-the-igf-subset-games-i-into-the-breach-i))
- เกมทำให้การโจมตีของศัตรูถูก **telegraph** และต้องการให้ความพ่ายแพ้รู้สึกเป็นผลจากการตัดสินใจของผู้เล่น ([2](https://www.gamedeveloper.com/game-platforms/road-to-the-igf-subset-games-i-into-the-breach-i))

**บทเรียนที่นำไปทดลองกับ Blink Arcana**

1. แสดง **เจตนาศัตรู ผลของการกระทำ และผลกระทบต่อพื้นที่** ก่อนยืนยันคำสั่ง เพื่อให้ความยากมาจากการวางแผน/แก้โจทย์ ไม่ใช่ข้อมูลที่ซ่อนอยู่หรือความสุ่มที่ผู้เล่นคาดเดาไม่ได้
2. ทำเป้าหมายหลายชั้น เช่น ปกป้องสิ่งก่อสร้างหรือวัตถุสำคัญควบคู่กับการกำจัดศัตรู เพื่อสร้างการตัดสินใจว่าอะไรควรยอมเสียและอะไรต้องรักษา โดยไม่จำเป็นต้องเพิ่มกฎจำนวนมาก
3. ออกแบบความสามารถให้เปลี่ยนสถานการณ์เชิงพื้นที่ได้ เช่น ผลักศัตรูหรือเปลี่ยนผลของตำแหน่ง ไม่ใช่เพิ่มเพียงค่าความเสียหาย เพื่อให้ผู้เล่นสร้างวิธีแก้ใหม่จากปฏิสัมพันธ์ของระบบ
4. แยกแกนเกมหลักที่อ่านง่ายออกจากเนื้อหาเสริมที่ซับซ้อน หากพอร์ตจาก Android ไป desktop ควรทบทวนทุกหน้าต่าง UI ทั้งภาระข้อมูล องค์ประกอบที่ยุบได้ ขนาดปุ่ม และรูปแบบการโต้ตอบให้เหมาะกับแพลตฟอร์ม ([3](https://toucharcade.com/2022/08/08/into-the-breach-mobile-interview-subset-games-ftl-nintendo-switch-netflix-games-ipad-iphone/))

**ข้อจำกัดและสิ่งที่ยืนยันไม่ได้**

- ไม่ควรใช้เป็นแม่แบบโครงสร้างระบบของ Blink Arcana เพราะเกมเน้นการต่อสู้เชิงปริศนาและการวางแผนขนาดกะทัดรัด มากกว่า RPG ที่มีบทบาทตัวละคร/การพัฒนาแบบ RPG
- แหล่งสัมภาษณ์ระบุ C++, Visual Studio และ Lua แต่ **ไม่ได้ระบุชื่อ game engine** จึงยืนยันไม่ได้ว่าใช้เอนจินสำเร็จรูปหรือเอนจินที่สร้างเอง ([2](https://www.gamedeveloper.com/game-platforms/road-to-the-igf-subset-games-i-into-the-breach-i))
- บทเรียน UI จากพอร์ตมือถือเป็นหลักการที่นำมาปรับใช้ได้ ไม่ใช่หลักฐานเฉพาะว่าการย้าย Android ไป desktop ของ Blink Arcana จะมีวิธีเดียวกัน

### The Last Spell

**ลักษณะและความเกี่ยวข้อง**

- เป็น Tactical RPG/turn-based strategy ผสาน roguelite: จัดการฮีโร่และทรัพยากร สร้าง/ซ่อมป้อมปราการช่วงกลางวัน แล้วสู้กับคลื่นศัตรูตอนกลางคืน ([4](https://store.steampowered.com/app/1105670/The_Last_Spell/))
- โครงสร้างนี้เชื่อมการเตรียมฮีโร่/เมืองกับผลลัพธ์ในสนามรบ และใช้ฮีโร่จำนวนน้อย Action Points/การรักษาที่จำกัด และตำแหน่งป้องกันเป็นข้อจำกัดที่อ่านได้ ([5](https://www.gamedeveloper.com/design/deep-dive-designing-a-new-dwarf-race-in-the-last-spell))

**บทเรียนที่นำไปทดลอง**

1. ทำลูปหนึ่งรอบให้ชัด: ช่วงเตรียมทีม/เมือง → ช่วงต่อสู้ และทำให้การใช้ทรัพยากรช่วงแรกเห็นผลในสนามช่วงถัดไป
2. ผูกแท็กเชิงยุทธวิธีกับต้นทุนจริง เช่น จำนวนตัวละครน้อย AP จำกัด การรักษาจำกัด และจุดป้องกัน เพื่อให้การเลือกเป้าหมาย/พื้นที่โจมตีมีความหมาย
3. เมื่อต้องเพิ่ม archetype ให้ระบุอัตลักษณ์ด้วยชุดคุณลักษณะและความสามารถหลักที่เข้าใจได้ทันที แล้วทดสอบหลายสถานการณ์และหลายช่วงความก้าวหน้า นักออกแบบเกมอธิบายการทดสอบซ้ำและรับฟังข้อเสนอแนะผู้เล่นไว้ในแหล่งข้อมูล ([5](https://www.gamedeveloper.com/design/deep-dive-designing-a-new-dwarf-race-in-the-last-spell))
4. สื่อสารคอนเซปต์ด้วยภาพเกมเพลย์จริง/เดโมที่เห็นฮีโร่ ศัตรู พื้นที่ป้องกัน และ UI ในภาพเดียว เพื่อให้ผู้เล่นเข้าใจแนวเกมเร็ว ([6](https://newsletter.gamediscover.co/p/the-last-spell-how-we-surprised-ourselves))

**ข้อจำกัดและสิ่งที่ยืนยันไม่ได้**

- เป็นเกมเดสก์ท็อปเชิงพาณิชย์ที่บริหารเมืองและรับมือคลื่นศัตรูจำนวนมาก จึงไม่ใช่หลักฐานตรงสำหรับ Android-to-desktop migration ของ Blink Arcana
- หน้าเกม/บทความที่ให้มา **ไม่ยืนยันเอนจิน** และไม่ยืนยัน Godot, GDScript, Rust หรือสถาปัตยกรรมภายใน จึงไม่ควรอนุมานจากหน้าตาเกม

### Battle Brothers

**ลักษณะและความเกี่ยวข้อง**

- เป็น tactical RPG/turn-based strategy RPG แนวแฟนตาซียุคกลาง มีแคมเปญโลกเปิดแบบ procedural และการต่อสู้ผลัดกันเดิน ([7](https://store.steampowered.com/app/365360/Battle_Brothers/))
- แหล่งจากผู้พัฒนากล่าวถึงสนามรบที่ทำให้ภูมิประเทศ ระดับความสูง สิ่งกีดขวาง ตำแหน่ง และอาวุธ/ศัตรูที่แตกต่างกันเปลี่ยนการตัดสินใจในแต่ละเทิร์น ([8](https://battlebrothersgame.com/dev-blog-3-designing-the-combat-system-for-battle-brothers/))

**บทเรียนที่นำไปทดลอง**

1. สร้างความหลากหลายจากระบบที่ส่งผลต่อกัน: procedural battlefield + ภูมิประเทศ/ระดับสูงต่ำ + ศัตรูที่มีพฤติกรรมต่างกัน ทำให้เกิดสถานการณ์ใหม่โดยไม่ต้องสร้างฉากเฉพาะจำนวนมหาศาล
2. ออกแบบทางเลือกแบบ **ข้อดีแลกข้อเสีย** ไม่ใช่ลำดับอัปเกรดตรง ๆ เช่น อุปกรณ์ที่ป้องกันดีกว่าอาจสะสมความเหนื่อยล้าเร็วกว่า เพื่อให้ build เหมาะกับบริบทต่างกัน ([8](https://battlebrothersgame.com/dev-blog-3-designing-the-combat-system-for-battle-brothers/))
3. ใช้ศัตรูหรือสถานการณ์ที่เป็น **combo-breaker** เจาะจงกลยุทธ์หลัก แทนการเพิ่มเพียง HP/ความเสียหาย และทำให้เหตุผลของภูมิประเทศ/ตำแหน่งอ่านได้จากตรรกะที่คุ้นเคย
4. จัดการขอบเขตและการผลิตตั้งแต่ต้น: ผู้พัฒนาเล่าว่าเริ่มเป็นงานอดิเรก ขยายหลัง Early Access และต้องปรับแนวคิดระหว่างพัฒนา รวมถึงพบว่าการวางแผนระบบ asset การแปล และ mod support ล่วงหน้าสำคัญ ([10](https://turnbasedlovers.com/10-turns-interview/with-battle-brothers-developer/))

**ข้อจำกัดและสิ่งที่ยืนยันไม่ได้**

- โครงสร้างแคมเปญบริหารกองทหารรับจ้างและ permadeath ต่างจาก Blink Arcana และข้อมูลไม่ได้พิสูจน์ว่าแนวทางเดียวกันเหมาะกับ Android หรือการพอร์ตไป desktop
- มีหลักฐานว่าใช้เอนจินที่ Overhype Studios เขียนเองด้วย C++, ใช้ Squirrel สำหรับ gameplay scripting และ Awesomium สำหรับ UI แบบ HTML จากประกาศรับสมัครของทีม ([9](https://battlebrothersgame.com/ui-programmer-wanted/)) แต่ข้อมูลนี้เป็นประกาศช่วงพัฒนาเกม ไม่ใช่คำอธิบายสถาปัตยกรรมหรือกระบวนการพอร์ตทั้งหมด

## 1.2 เกมที่ผลค้นคว้ายืนยันว่าใช้ Godot

> ส่วนนี้แยกออกจาก tactical-design case studies ตามคำขอ เกมด้านล่างยืนยันได้เรื่อง Godot แต่ **ไม่ได้เป็นหลักฐานว่า Blink Arcana ควรใช้โครงสร้างหรือระบบเดียวกัน**

### Dome Keeper — ยืนยัน Godot

- บทสัมภาษณ์ Game Developer ระบุโดยตรงว่าสร้างด้วย **Godot Engine** พร้อมใช้ Aseprite สำหรับ pixel art และ Logic Pro/Ableton สำหรับเสียงและดนตรี ([11](https://www.gamedeveloper.com/business/how-dome-keeper-focuses-on-systems-that-feed-into-one-another))
- หน้า showcase ทางการของ Godot ก็ระบุ Dome Keeper โดย Bippinbits ([12](https://godotengine.org/showcase/dome-keeper/))
- เป็นเกม roguelike/rogue-lite survival miner: ขุดทรัพยากรระหว่างคลื่นศัตรู แล้วใช้อัปเกรดเพื่อรับมือการโจมตีถัดไป ([13](https://rawfury.com/announcing-dome-keeper/))

**บทเรียนที่ถ่ายโอนได้**

1. ให้ระบบหนึ่งสร้างแรงจูงใจและข้อจำกัดแก่อีกระบบ: การขุดให้ทรัพยากร แต่คลื่นศัตรูบังคับให้ตัดสินใจว่าจะขุดต่อหรือกลับฐาน
2. คงกติกาพื้นฐานให้เข้าใจง่าย แล้วสร้างความลึกจากปฏิสัมพันธ์ของระบบ แทนการทำให้ทุกกลไกซับซ้อนแยกจากกัน
3. ทำให้อัปเกรดแตกต่างอย่างมีความหมายและมี feedback ทางภาพ/เสียงทันที
4. อย่าสับสนระหว่าง “ยืนยันใช้ Godot” กับ “ยืนยันเวอร์ชัน/ภาษา”: ผลค้นคว้า **ไม่ยืนยัน Godot 4, GDScript หรือ Rust GDExtension** และเกมเป็นแอ็กชันมุมมองด้านข้างแบบเรียลไทม์ ไม่ใช่ tactical grid RPG

### Brotato — ยืนยัน Godot

- หน้า showcase ของ Godot ระบุ Brotato โดย Blobfish และเชื่อมไปหน้า Steam จึงยืนยันได้ว่าเกมอยู่ใน ecosystem ของ Godot จากแหล่งของเจ้าของเอนจิน ([14](https://godotengine.org/showcase/brotato/))
- หน้า Steam ระบุลูปเอาตัวรอดเป็น wave มีช่วงซื้อไอเท็ม และการเล็ง/ยิงอัตโนมัติเป็นค่าเริ่มต้นพร้อมตัวเลือกเล็งเอง รวมถึงตัวละครและอาวุธ/ไอเท็มจำนวนมาก ([15](https://store.steampowered.com/app/1942280/Brotato/))
- เป็น top-down arena shooter/bullet heaven แบบเรียลไทม์ ไม่ใช่ tactical grid RPG; The Atlantic กล่าวถึงรูปลักษณ์การ์ตูนและภาพที่ไม่เน้นความละเอียดสูง แต่ไม่ได้ให้รายละเอียด pipeline เชิงเทคนิค ([16](https://www.theatlantic.com/ideas/archive/2023/03/brotato-video-game-potato-vampire-survivors/673405/))

**บทเรียนที่ถ่ายโอนได้**

1. แบ่งปะทะสั้นกับช่วงพักให้หน้าที่ชัด เพื่อให้การเตรียม build และการตัดสินใจไม่ถูกกลืนด้วยจังหวะต่อสู้
2. ลดภาระการควบคุมด้วยการช่วยเลือก/แสดงระยะและพื้นที่โจมตีได้ แต่คงการตัดสินใจเรื่องตำแหน่งและเป้าหมายไว้สำหรับเกม grid
3. สร้างความหลากหลายจากการผสมตัวเลือกที่เปลี่ยน build และมี trade-off แทนการเพิ่มคอนเทนต์แบบแยกชิ้น
4. คุม scope ให้แกนเกมสมบูรณ์ และพิจารณาตัวเลือกปรับ HP/ความเสียหาย/ความเร็วศัตรูเป็นแนวทางการเข้าถึงง่าย โดยไม่ยกจังหวะความหนาแน่นของศัตรูหรือการควบคุมแบบเรียลไทม์มาใช้ตรง ๆ

**สิ่งที่ยืนยันไม่ได้:** แหล่งที่ให้มาไม่ระบุเวอร์ชัน Godot หรือเทคโนโลยีภายในอื่น จึงไม่ควรอ้าง Godot 4, GDScript หรือ Rust จากข้อมูลชุดนี้

## 1.3 ตารางเปรียบเทียบเพื่อเลือกบทเรียน

| เกม | สิ่งที่เหมาะนำไปทดลองใน Blink Arcana | ไม่ควรสรุปเกินหลักฐาน |
|---|---|---|
| Into the Breach | telegraph, เป้าหมายหลายชั้น, ผลัก/เปลี่ยนตำแหน่ง, UI ที่ลดข้อมูลเกินจำเป็น | ไม่ใช่ tactical grid RPG เต็มรูปแบบ; เอนจินไม่ยืนยัน |
| The Last Spell | ลูปเตรียมการ–ต่อสู้, AP/การรักษา/พื้นที่เป็นข้อจำกัด, ทดสอบ archetype, เดโมสื่อสารคอนเซปต์ | เอนจินและสถาปัตยกรรมไม่ยืนยัน; ไม่ใช่หลักฐานการพอร์ต |
| Battle Brothers | ภูมิประเทศ/ระดับสูงต่ำ, ข้อดีแลกข้อเสีย, combo-breaker, วางแผน asset และ scope | ใช้เอนจินเขียนเองตามประกาศทีม; ไม่ใช่หลักฐานว่าเหมาะกับ Android |
| Dome Keeper | ระบบต่างจังหวะที่ป้อนแรงจูงใจให้กัน, feedback อัปเกรด, ความลึกจากปฏิสัมพันธ์ | ยืนยัน Godot แต่ไม่ยืนยันเวอร์ชัน/ภาษา; ไม่ใช่ grid RPG |
| Brotato | ช่วงปะทะ–พัก, build จากตัวเลือก, ลดภาระการควบคุม, คุม scope/ปรับความยาก | ยืนยัน Godot จาก showcase แต่เป็น arena action เรียลไทม์; pipeline ภาพไม่ยืนยัน |

---

# 2) ตัวเลือก Assets หลายทาง พร้อมสิทธิ์และข้อควรระวัง

## หลักตรวจสอบร่วม

- “ดาวน์โหลดฟรี” ไม่เท่ากับ “ใช้เชิงพาณิชย์ได้”: รายการด้านล่างยึดคำประกาศใบอนุญาตจากหน้าผู้สร้าง/ไฟล์ License ที่ผลค้นคว้าระบุ
- **CC0** ในรายการ Kenney อนุญาตคัดลอก ดัดแปลง แจกจ่าย และใช้เชิงพาณิชย์ตามข้อมูลที่ให้มา แต่ไม่ได้โอนสิทธิ์เครื่องหมายการค้า สิทธิส่วนบุคคล/ภาพลักษณ์ หรือสิทธิของบุคคลอื่น และไม่ควรสื่อว่า Kenney รับรอง Blink Arcana ([24](https://creativecommons.org/publicdomain/zero/1.0/), [25](https://creativecommons.org/publicdomain/zero/1.0/legalcode.en))
- **CC BY 4.0** ของ Toen อนุญาตใช้และดัดแปลงเชิงพาณิชย์ แต่ต้องให้เครดิต ลิงก์ใบอนุญาต และระบุว่ามีการแก้ไขหรือไม่ อีกทั้งห้ามเพิ่มข้อจำกัดทางกฎหมาย/เทคโนโลยีที่ลดสิทธิซึ่งใบอนุญาตอนุญาต ([20](https://creativecommons.org/licenses/by/4.0/))
- ควรเก็บสำเนา License.txt/ข้อมูล attribution และบันทึก asset ที่ใช้จริงในโปรเจกต์ แม้ใบอนุญาตจะไม่บังคับเครดิต

## 2.1 ตารางคัดเลือก Assets

| Asset | เหมาะใช้กับ Blink Arcana | ใบอนุญาต/การค้า | Attribution และ redistribution | ข้อควรระวัง/สิ่งที่ยังยืนยันไม่ได้ |
|---|---|---|---|---|
| **Toen’s Medieval Strategy Sprite Pack v.1.0 (16×16)** ([17](https://opengameart.org/content/toens-medieval-strategy-sprite-pack-v10-16x16), [18](https://toen.itch.io/toens-medieval-strategy) | Tileset สำหรับ turn-based strategy/RPG มี terrain, อาคาร, roads, rivers, bridges, กองกำลัง, siege weapons, effects และ GUI; ผู้สร้างระบุสูงสุด 308 ชิ้น ช่องกริด 16×16 | **CC BY 4.0**; ใช้/ดัดแปลงเชิงพาณิชย์ได้ | ต้องให้เครดิต Andre Mari Coppola, ใส่ลิงก์ใบอนุญาต/แหล่งที่มา และระบุการแก้ไข; แจกจ่ายซ้ำ/ดัดแปลงได้ภายใต้เงื่อนไข attribution ([19](https://opengameart.org/sites/default/files/Toen%27s%20Medieval%20Strategy%20Sprite%20Pack%20v.1.0%20%20%2816x16%29.zip) ระบุข้อมูลในไฟล์ license) | ธีม medieval strategy อาจต้องปรับสี/เพิ่มอาร์ตเฉพาะสำหรับ Arcana; ไม่ได้ระบุขนาด atlas รวม; ลิงก์ ZIP เป็นแหล่งอ้างอิงเท่านั้น ไม่ได้ดาวน์โหลดในการทำรายงาน |
| **Kenney — Roguelike/RPG pack** ([21](https://kenney.nl/assets/roguelike-rpg-pack)) | ฐาน pixel-art tile 16×16 มีเนื้อหา RPG/roguelike, เมือง, เฟอร์นิเจอร์, ปุ่ม/แผง UI และตัวอย่าง Tiled; หน้าทางการระบุ 1700× | **CC0 1.0**; ใช้เชิงพาณิชย์และดัดแปลงได้ | ไม่บังคับเครดิต; แจกจ่ายเป็นส่วนหนึ่งของเกม/งานดัดแปลงได้ตาม CC0 | Kenney ขอไม่ให้นำโลโก้ไปใช้; ไม่สื่อการรับรอง; CC0 ไม่ครอบคลุม trademark/สิทธิบุคคลอื่น/การรับประกัน; จำนวน 1700× เป็นตัวเลขหน้าแพ็ก ไม่ใช่การยืนยันจำนวนไฟล์ ZIP ([22](https://kenney.nl/support), [23](https://kenney.nl/media/pages/assets/roguelike-rpg-pack/12c03cd78b-1677697420/kenney_roguelike-rpg-pack.zip)) |
| **Tiny Dungeon (1.0)** ([26](https://kenney.nl/assets/tiny-dungeon)) | pixel-art dungeon/RPG/roguelike tile 16×16 มี tiles, ตัวละคร, อาวุธ, ไอเท็ม และตัวอย่าง Tiled; เหมาะกับดันเจียน/encounter grid | **CC0 1.0**; ใช้ในโครงการส่วนตัว การศึกษา และเชิงพาณิชย์ได้ | ไม่บังคับเครดิต; CC0 อนุญาตคัดลอก/แก้ไข/แจกจ่าย/ใช้เพื่อการค้า | ห้ามใช้โลโก้ Kenney; ไม่สื่อ endorsement และต้องระวัง trademark/สิทธิบุคคลอื่น/ไม่มีการรับประกัน; ตัวเลข 130×/มากกว่า 130 sprites ไม่ใช่จำนวนไฟล์ ZIP ทั้งหมด ([27](https://kenney-assets.itch.io/tiny-dungeon), [28](https://kenney.nl/media/pages/assets/tiny-dungeon/f8422efb44-1674742415/kenney_tiny-dungeon.zip)) |
| **UI Pack (เวอร์ชัน 2.0)** ([29](https://kenney.nl/assets/ui-pack)) | ชุด UI 2D สำหรับปุ่ม แผง slider/HUD/เมนู มีหลายสีและ sprite แยก; หน้าเจ้าของระบุ 400+ sprites/หน้าแพ็กระบุ 430× | **CC0 1.0**; ใช้เชิงพาณิชย์ได้ | ไม่บังคับเครดิต; แจกจ่าย/ดัดแปลงได้ตาม CC0 | หน้าผู้สร้างระบุ vector source files และไม่ระบุว่าเป็น pixel art จึง **ยังยืนยันความเข้ากับ pixel-art ไม่ได้**; ต้องทดสอบสเกล/การเรนเดอร์; ห้ามใช้โลโก้ Kenneyและไม่สื่อ endorsement ([30](https://kenney-assets.itch.io/ui-pack), [31](https://kenney.nl/media/pages/assets/ui-pack/f651646eab-1718203990/kenney_ui-pack.zip)) |
| **RPG Audio** ([32](https://kenney.nl/assets/rpg-audio)) | Foley SFX 50 ไฟล์ เช่น footsteps, หนังสือ, ผ้า/เข็มขัด, ประตู, เหรียญ, โลหะ และมีด; ใช้เสริม feedback ของ RPG | **CC0 1.0**; ใช้เชิงพาณิชย์ได้ | ไม่บังคับเครดิต; คัดลอก/ดัดแปลง/แจกจ่ายได้ตาม CC0 | ไม่ใช่ชุดเสียง tactical UI, เวทมนตร์, อาวุธครบชุด หรือเพลง; ควรฟัง preview และทดสอบโทนก่อนใช้; ข้อมูลผลค้นคว้ายืนยันจำนวนไฟล์/รายการเสียง แต่ไม่ใช่การรับรองว่าเหมาะกับทุกฉาก ([33](https://kenney.nl/media/pages/assets/rpg-audio/8e99002d76-1677590336/kenney_rpg-audio.zip)) |

## 2.2 สรุปการปฏิบัติตามใบอนุญาต

### กรณีเลือก Toen’s Medieval Strategy Sprite Pack

ใส่เครดิตในหน้า Credits/เอกสารประกอบเกมในลักษณะที่ระบุชื่อผู้สร้าง **Andre Mari Coppola**, ชื่อแพ็ก, ลิงก์แหล่งที่มา และลิงก์ [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) พร้อมระบุว่าแก้ไขหรือไม่ตามการใช้งานจริง ข้อมูลใน ZIP ต้นฉบับมีไฟล์ “License and atribution info.txt” ตามผลค้นคว้า ([19](https://opengameart.org/sites/default/files/Toen%27s%20Medieval%20Strategy%20Sprite%20Pack%20v.1.0%20%20%2816x16%29.zip))

ตัวอย่างข้อความที่ควรปรับให้ตรงกับการใช้งานจริง:

> “กราฟิกบางส่วนดัดแปลงจาก Toen’s Medieval Strategy Sprite Pack โดย Andre Mari Coppola, ใช้ภายใต้ CC BY 4.0: https://creativecommons.org/licenses/by/4.0/ — มีการแก้ไข: [ระบุจริง/ไม่มีการแก้ไข]”

### กรณีเลือก asset ของ Kenney

เครดิตไม่บังคับตามข้อมูลหน้า Support และ License.txt แต่หากต้องการให้เครดิตให้กล่าวถึง “Kenney” หรือ “kenney.nl” ได้ ห้ามใช้โลโก้ของ Kenney และไม่ควรเขียนหรือออกแบบให้ผู้เล่นเข้าใจว่า Kenney รับรอง Blink Arcana ([22](https://kenney.nl/support))

### การแจกจ่ายต่อ

- CC0: แจกจ่าย asset ที่รวมอยู่ในเกม/ผลงานดัดแปลงได้ตามข้อมูลที่ให้มา แต่ยังต้องไม่อ้างสิทธิ์ในเครื่องหมายการค้า โลโก้ หรือสิทธิของบุคคลอื่น
- CC BY: แจกจ่าย/ดัดแปลงได้เมื่อยังคงเงื่อนไข attribution และไม่เพิ่มข้อจำกัดที่ขัดกับใบอนุญาต
- ผลค้นคว้า **ไม่ได้ยืนยัน** ข้อเท็จจริงอื่นนอกข้อความใบอนุญาตที่ระบุ เช่น สิทธิขององค์ประกอบภายนอกที่อาจอยู่ในงาน หรือข้อกำหนดของแพลตฟอร์มจำหน่ายเกม จึงควรตรวจสอบทรัพย์สินที่ใช้จริงและนโยบายแพลตฟอร์มแยกต่างหากก่อนเปิดตัว

---

# 3) Shortlist แนะนำสำหรับ Blink Arcana

Shortlist นี้เป็นการจัดลำดับจากความเหมาะสมตามข้อมูลที่ให้มา **ไม่ใช่การอนุมัติขั้นสุดท้าย** และไม่มีการติดตั้ง/ดาวน์โหลดเพื่อทดสอบ

## A. ชุดเริ่มต้นสำหรับ tactical grid RPG

1. **Kenney — Roguelike/RPG pack (CC0)**
   - เลือกเมื่ออยากได้ฐานกว้างสำหรับต้นแบบ: tile 16×16, เมือง/อาคาร/terrain, RPG/roguelike และ UI เบื้องต้น
   - เหตุผลเชิงผลิตภัณฑ์: ลดภาระ attribution และมีองค์ประกอบพอให้ทดลอง grid, ฉาก และ onboarding
   - ตรวจต่อก่อนใช้จริง: look-and-feel ของ Arcana, ความครบของ sprites ที่ต้องการ และข้อห้ามโลโก้/endorsement

2. **Toen’s Medieval Strategy Sprite Pack (CC BY 4.0)**
   - เลือกเมื่อให้ความสำคัญกับภาพสนามรบแนว strategy และโครงสร้าง tileset 16×16 ที่ผู้สร้างทำสำหรับ turn-based strategy/RPG
   - เหตุผลเชิงผลิตภัณฑ์: มี terrain อาคาร กองกำลัง siege weapons effects และ GUI ในธีมเดียว
   - เงื่อนไขสำคัญ: ต้องวางแผนเครดิต Andre Mari Coppola และบันทึกการแก้ไข; ธีม medieval อาจต้องทำอาร์ต Arcana เพิ่ม

## B. ส่วนเสริมที่ควรพิจารณาแยกจาก tileset

3. **Tiny Dungeon (CC0)**
   - ใช้เมื่อ Blink Arcana ต้องมีดันเจียน ตัวละคร อาวุธ และไอเท็มแบบ pixel-art 16×16
   - เหมาะเป็นชุดเสริม/ต้นแบบ encounter มากกว่าจะถือว่าเป็นภาพหลักของทั้งเกมโดยอัตโนมัติ

4. **UI Pack 2.0 (CC0)**
   - ใช้เป็นตัวเลือกปุ่ม แผง slider และ HUD/เมนู
   - ต้องทดสอบอย่างจริงจังกับ pixel-art เพราะข้อมูลที่ให้มาระบุ vector source files แต่ไม่ยืนยัน pixel-art compatibility

5. **RPG Audio (CC0)**
   - ใช้เติม Foley feedback เช่น ฝีเท้า ประตู เหรียญ และการจัดการอุปกรณ์
   - ไม่ควรถือเป็นชุดเสียงเวทมนตร์/การต่อสู้/เพลง เพราะแหล่งข้อมูลไม่ได้ยืนยันเช่นนั้น

## C. บทเรียนระบบที่ควรทำเป็นงานออกแบบก่อนผลิต asset

- ทำ enemy intent และผลคำสั่งให้เห็นก่อนยืนยัน (Into the Breach)
- วางลูปเตรียมทีม–ต่อสู้ และกำหนดทรัพยากรที่มีต้นทุนจริง (The Last Spell)
- ให้ภูมิประเทศ ตำแหน่ง และข้อดีแลกข้อเสียเปลี่ยนการตัดสินใจ (Battle Brothers)
- ใช้ feedback ภาพ/เสียงกับอัปเกรด และสร้างความลึกจากระบบที่ป้อนแรงจูงใจให้กัน (Dome Keeper ซึ่งยืนยัน Godot)
- แยกช่วงปะทะกับช่วงพัก และคุม scope/build ให้ผู้เล่นเข้าใจได้ (Brotato ซึ่งยืนยัน Godot)

## สิ่งที่ยังยืนยันไม่ได้และห้ามอ้างเกินแหล่ง

- ผลค้นคว้า **ไม่ยืนยัน** ว่า Blink Arcana ใช้ Godot, Godot 4, GDScript, Rust หรือ Rust GDExtension
- ผลค้นคว้า **ไม่ยืนยัน** ว่า asset ใดเข้ากับ art direction สุดท้าย, ประสิทธิภาพ desktop, การแสดงผลจาก Android หรือ pipeline โปรเจกต์โดยไม่ต้องทดลอง
- ผลค้นคว้า **ไม่ยืนยัน** จำนวนไฟล์ทั้งหมดของบางแพ็กจากตัวเลข “×” บนหน้าเว็บ เพราะตัวเลขดังกล่าวอาจหมายถึงจำนวน asset/sprite ตามที่หน้าอธิบาย ไม่ใช่จำนวนไฟล์ใน ZIP
- ผลค้นคว้า **ไม่ยืนยัน** สิทธิ์ขององค์ประกอบภายนอกหรือบุคคลอื่นที่อาจเกี่ยวข้องกับการใช้งานจริงนอกข้อความใบอนุญาตที่อ้างถึง
- ห้ามอ้างว่าเกมตัวอย่างใช้เอนจินใดจากรูปลักษณ์ ภาษาโปรแกรม หรือ wiki ที่ไม่ได้อยู่ในผลค้นคว้า: Into the Breach และ The Last Spell ไม่ยืนยันเอนจิน; Battle Brothers ยืนยันเพียงเอนจินของทีมเองตามประกาศรับสมัครในช่วงพัฒนา; Dome Keeper และ Brotato ยืนยัน Godot ตามแหล่งที่ระบุ แต่ไม่ยืนยันเวอร์ชันหรือภาษาสคริปต์

---

# References

[1]: https://subsetgames.com/itb.html "Subset Games — Into the Breach"

[2]: https://www.gamedeveloper.com/game-platforms/road-to-the-igf-subset-games-i-into-the-breach-i "Game Developer — Road to the IGF: Subset Games’ Into the Breach"

[3]: https://toucharcade.com/2022/08/08/into-the-breach-mobile-interview-subset-games-ftl-nintendo-switch-netflix-games-ipad-iphone/ "TouchArcade — Into the Breach mobile interview"

[4]: https://store.steampowered.com/app/1105670/The_Last_Spell/ "Steam — The Last Spell"

[5]: https://www.gamedeveloper.com/design/deep-dive-designing-a-new-dwarf-race-in-the-last-spell "Game Developer — Designing a new dwarf race in The Last Spell"

[6]: https://newsletter.gamediscover.co/p/the-last-spell-how-we-surprised-ourselves "GameDiscoverCo — The Last Spell: How we surprised ourselves"

[7]: https://store.steampowered.com/app/365360/Battle_Brothers/ "Steam — Battle Brothers"

[8]: https://battlebrothersgame.com/dev-blog-3-designing-the-combat-system-for-battle-brothers/ "Battle Brothers — Dev Blog 3: Designing the combat system"

[9]: https://battlebrothersgame.com/ui-programmer-wanted/ "Overhype Studios — UI Programmer Wanted"

[10]: https://turnbasedlovers.com/10-turns-interview/with-battle-brothers-developer/ "TurnBasedLovers — Interview with Battle Brothers developer"

[11]: https://www.gamedeveloper.com/business/how-dome-keeper-focuses-on-systems-that-feed-into-one-another "Game Developer — How Dome Keeper focuses on systems that feed into one another"

[12]: https://godotengine.org/showcase/dome-keeper/ "Godot Engine Showcase — Dome Keeper"

[13]: https://rawfury.com/announcing-dome-keeper/ "Raw Fury — Announcing Dome Keeper"

[14]: https://godotengine.org/showcase/brotato/ "Godot Engine Showcase — Brotato"

[15]: https://store.steampowered.com/app/1942280/Brotato/ "Steam — Brotato"

[16]: https://www.theatlantic.com/ideas/archive/2023/03/brotato-video-game-potato-vampire-survivors/673405/ "The Atlantic — Brotato"

[17]: https://opengameart.org/content/toens-medieval-strategy-sprite-pack-v10-16x16 "OpenGameArt — Toen’s Medieval Strategy Sprite Pack v1.0 (16×16)"

[18]: https://toen.itch.io/toens-medieval-strategy "itch.io — Toen’s Medieval Strategy"

[19]: https://opengameart.org/sites/default/files/Toen%27s%20Medieval%20Strategy%20Sprite%20Pack%20v.1.0%20%20%2816x16%29.zip "OpenGameArt — Original ZIP for Toen’s Medieval Strategy Sprite Pack"

[20]: https://creativecommons.org/licenses/by/4.0/ "Creative Commons — CC BY 4.0"

[21]: https://kenney.nl/assets/roguelike-rpg-pack "Kenney — Roguelike/RPG pack"

[22]: https://kenney.nl/support "Kenney — Support / licensing FAQ"

[23]: https://kenney.nl/media/pages/assets/roguelike-rpg-pack/12c03cd78b-1677697420/kenney_roguelike-rpg-pack.zip "Kenney — Roguelike/RPG pack ZIP"

[24]: https://creativecommons.org/publicdomain/zero/1.0/ "Creative Commons — CC0 1.0 Deed"

[25]: https://creativecommons.org/publicdomain/zero/1.0/legalcode.en "Creative Commons — CC0 1.0 Legal Code"

[26]: https://kenney.nl/assets/tiny-dungeon "Kenney — Tiny Dungeon"

[27]: https://kenney-assets.itch.io/tiny-dungeon "itch.io — Tiny Dungeon by Kenney"

[28]: https://kenney.nl/media/pages/assets/tiny-dungeon/f8422efb44-1674742415/kenney_tiny-dungeon.zip "Kenney — Tiny Dungeon ZIP"

[29]: https://kenney.nl/assets/ui-pack "Kenney — UI Pack"

[30]: https://kenney-assets.itch.io/ui-pack "itch.io — UI Pack by Kenney"

[31]: https://kenney.nl/media/pages/assets/ui-pack/f651646eab-1718203990/kenney_ui-pack.zip "Kenney — UI Pack ZIP"

[32]: https://kenney.nl/assets/rpg-audio "Kenney — RPG Audio"

[33]: https://kenney.nl/media/pages/assets/rpg-audio/8e99002d76-1677590336/kenney_rpg-audio.zip "Kenney — RPG Audio ZIP"
