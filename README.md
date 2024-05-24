## A Minetest Mod

This is a Minetest mod that can turns real lights and switchs on and off in your house with in a MineTest virtual world. 
This mod interactic with the mese mod so you can connect lines en buttons to it.
The mod use the API of your internal [Home Assistant](https://www.home-assistant.io/) to turn lights en switches on and off

### Setup
Create in your Home Assistant appliance a long life token. 
In Minetest under settings -> Content: Mods -> Home Assistant enter:

* **Home Assistant URL**: http://xxx.xxx.xxx.xxx:8123
* **Header Token**: (the long life token from Home Assistant you created)
* **Entity**: a default entity name (light.esphome-001)

You can find the Entityname in Home Assistant http://xxx.xxx.xxx.xxx:8123/config/entities
Current only light en switch are working. 

[MineTest Mod page](https://content.minetest.net/packages/Jeff/homeassistant/).

