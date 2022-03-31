# jim-shops
## QBCore QB-Menu based replacement for qb-shops


This script is designed to be a replacement for QB-Shops, making shops work perfectly with QB-Menu, QB-Input and QB-Target
Self explanatory, it's just qb-shops but qb-menu based.

Everything needed is in Config.lua and its essentially the same as qb-shop's config.

- Support for shop logos at the top of the menu
- Supports items that require jobs
- Supports Gun License being required
- Support for opening shops externally
- Ability to choose and spawn shop peds
- Digital Den shop locations
- Stash Support, adds ability to limit purchases between restarts
- Ability to hide blips for shops, might useful for a blackmarket shop

![FiveM_b2545_GTAProcess_6p8QLBWFay](https://user-images.githubusercontent.com/1885302/161044199-f2755428-b911-4205-b709-21d835c4b18e.jpg)
![FiveM_b2545_GTAProcess_MobSX714os](https://user-images.githubusercontent.com/1885302/161044075-b7ae850d-a242-4984-a984-52e780d87f48.jpg)
![FiveM_b2545_GTAProcess_nvrm4jU278](https://user-images.githubusercontent.com/1885302/161044087-c9eb8f8d-a4a5-4174-a048-73a610231abe.jpg)


You can easily add the event for default inventory shops to open through my script instead.

For example -

Simply change the event name:

```TriggerServerEvent("inventory:server:OpenInventory", "shop", "mine", Config.Items)```

To this:

```TriggerServerEvent("jim-shops:ShopOpen", "shop", "mine", Config.Items)```
