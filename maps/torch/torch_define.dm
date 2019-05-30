/datum/map/torch
	name = "Torch"
	full_name = "SEV Torch"
	path = "torch"
	flags = MAP_HAS_BRANCH | MAP_HAS_RANK

	admin_levels = list(7,8)
	empty_levels = list(9)
	accessible_z_levels = list("1"=1,"2"=3,"3"=1,"4"=1,"5"=1,"6"=1,"9"=30)
	overmap_size = 35
	overmap_event_areas = 34
	usable_email_tlds = list("torch.ec.scg", "torch.fleet.mil", "freemail.net", "torch.scg")

	allowed_spawns = list("Cryogenic Storage", "Cyborg Storage")
	default_spawn = "Cryogenic Storage"

	station_name  = "SEV Torch"
	station_short = "Torch"
	dock_name     = "TBD"
	boss_name     = "Nanotrasen Command"
	boss_short    = "NT"
	company_name  = "Sol Central Government"
	company_short = "SolGov"

	map_admin_faxes = list("NT Central Office")

	//These should probably be moved into the evac controller...
	shuttle_docked_message = "Âíèìàíèå âñåì: çàïóùåíà ïðîöåäóðà ïîäãîòîâêè ê ïîäïðîñòðàíñòâåííîìó ïðûæêó â ñëåäóþùèé ñåêòîð. Ðàñ÷åòíîå âðåìÿ îêîí÷àíèÿ çàðÿäêè ãåíåðàòîðà áëþñïåéñà: %ETD%."
	shuttle_leaving_dock = "Âíèìàíèå âñåì: ïîäãîòîâêà ê ïîäïðîñòðàíñòâåííîìó ïðûæêó çàâåðøåíà. Íà÷àòà ïðîöåäóðà áåçîïàñíîé àêòèâàöèè ãåíåðàòîðà ïîäïðîñòðàíñòâà. Ðàñ÷åòíîå âðåìÿ äî íà÷àëà ïðûæêà:  %ETA%."
	shuttle_called_message = "Âíèìàíèå âñåì: Ïðûæîê íà÷àëñÿ. Íà÷àòû ïîëåòíûå ïðîöåäóðû. Îñòàëîñü:  %ETA%."
	shuttle_recall_message = "Âíèìàíèå âñåì: Ïðûæîê îòìåí¸í, Âîçâðàùàéòåñü ê âûïîëíåíèþ ñâîèõ ðàáî÷èõ îáÿçàííîñòåé."

	evac_controller_type = /datum/evacuation_controller/starship

	default_law_type = /datum/ai_laws/solgov
	use_overmap = 1
	num_exoplanets = 1

	away_site_budget = 3
	id_hud_icons = 'maps/torch/icons/assignment_hud.dmi'

/datum/map/torch/setup_map()
	..()
	system_name = generate_system_name()
	minor_announcement = new(new_sound = sound('sound/AI/torch/commandreport.ogg', volume = 45))

/datum/map/torch/get_map_info()
	. = list()
	. +=  "Âû íàõîäèòåñü íà áîðòó <b>[station_name]</b>, èññëåäîâàòåëüñêîãî ñóäíà êîðïîðàöèè NT. Îñíîâíà&#255; ìèññè&#255; âàøåãî îáúåêòà - ïðîâåäåíèå èññëåäîâàíèé íà íåéòðàëüíîé òåððèòîðèè."
	return jointext(., "<br>")

/datum/map/torch/send_welcome()
	var/welcome_text = "<center><img src = sollogo.png /><br /><font size = 3><b>SEV Torch</b> Sensor Readings:</font><br>"
	welcome_text += "Îò÷åò ñãåíåðèðîâàí [stationdate2text()] â [stationtime2text()]</center><br /><br />"
	welcome_text += "<hr>Òåêóùà&#255; ñèñòåìà:<br /><b>[system_name()]</b><br /><br>"
	welcome_text += "Ñëåäóþùà&#255; ñèñòåìà äë&#255; ïðûæêà:<br /><b>[generate_system_name()]</b><br /><br>"
	welcome_text += "Äíåé äî Ñîëíå÷íîé Ñèñòåìû::<br /><b>[rand(15,45)] days</b><br /><br>"
	welcome_text += "Äíåé ñ ïîñëåäíåãî âèçèòà â ïîðò::<br /><b>[rand(60,180)] days</b><br /><hr>"
	welcome_text += "Ñåíñîðû ïîêàçàëè ñëåäóùèå îáúåêòû äëÿ èçó÷åíèÿ:<br />"
	var/list/space_things = list()
	var/obj/effect/overmap/torch = map_sectors["1"]
	for(var/zlevel in map_sectors)
		var/obj/effect/overmap/O = map_sectors[zlevel]
		if(O.name == torch.name)
			continue
		if(istype(O, /obj/effect/overmap/ship/landable)) //Don't show shuttles
			continue
		space_things |= O

	var/list/distress_calls
	for(var/obj/effect/overmap/O in space_things)
		var/location_desc = " íà òåêóùåì êâàäðàòå."
		if(O.loc != torch.loc)
			var/bearing = round(90 - Atan2(O.x - torch.x, O.y - torch.y),5) //fucking triangles how do they work
			if(bearing < 0)
				bearing += 360
			location_desc = ", ïî àçèìóòó [bearing]."
		if(O.has_distress_beacon)
			LAZYADD(distress_calls, "[O.has_distress_beacon][location_desc]")
		welcome_text += "<li>\A <b>[O.name]</b>[location_desc]</li>"

	if(LAZYLEN(distress_calls))
		welcome_text += "<br><b>Îáíàðóæåíû ñèãíàëû áåäñòâè&#255;</b><br>[jointext(distress_calls, "<br>")]<br>"
	else
		welcome_text += "<br>Ñèãíàëû áåäñòâè&#255; íå îáíàðóæàíû<br />"
	welcome_text += "<hr>"

	post_comm_message("SEV Torch Sensor Readings", welcome_text)
	minor_announcement.Announce(message = "New [GLOB.using_map.company_name] Update available at all communication consoles.")

/turf/simulated/wall //landlubbers go home
	name = "bulkhead"

/turf/simulated/floor
	name = "bare deck"

/turf/simulated/floor/tiled
	name = "deck"

/decl/flooring/tiling
	name = "deck"

/obj/machinery/computer/rdconsole/petrov
	name = "petrov fabricator console"
	id = 3

/turf/simulated/floor/shuttle_ceiling/torch
	color = COLOR_HULL

/turf/simulated/floor/shuttle_ceiling/torch/air
	initial_gas = list("oxygen" = MOLES_O2STANDARD, "nitrogen" = MOLES_N2STANDARD)
