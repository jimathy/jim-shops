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

![FiveM_b2545_GTAProcess_mYqo1bzn22](https://user-images.githubusercontent.com/1885302/160259437-e691b884-a707-422d-bbda-e86ecc5d3d50.jpg)
![FiveM_b2545_GTAProcess_3SZCVpXrEX](https://user-images.githubusercontent.com/1885302/160259455-0bbe9705-8469-41fb-bd5b-a6388cdc5392.jpg)


You can easily add the event for default inventory shops to open through my script instead.

For example -

Simply change the event name:

```TriggerServerEvent("inventory:server:OpenInventory", "shop", "mine", Config.Items)```

To this:

```TriggerServerEvent("jim-shops:ShopOpen", "shop", "mine", Config.Items)```
