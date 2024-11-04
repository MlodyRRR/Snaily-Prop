# Snaily Prop(Obiekt)

Zaawansowany system stawiania proprów(obiektów).

## Wymagania
- ox_lib
- ox_inventory
- ox_target

## Instalacja
1. Skopiuj folder `snaily-prop` do katalogu `resources`
2. Dodaj `ensure snaily-prop` do server.cfg
3. Dodaj przedmioty do ox_inventory/data/items.lua:
```lua
['barierka'] = {
    label = 'Barierka',
    weight = 500,
    stack = true,
    close = true,
},
['pacholek'] = {
    label = 'Pachołek',
    weight = 500,
    stack = true,
    close = true,
},
```

## Konfiguracja
W pliku `config.lua` możesz:
- Dostosować prędkość ruchu i obrotu obiektów
- Zmienić animacje i czas ich trwania
- Dodać własne propy(obiekty)
- Dostosować notyfikacje i progressbary do swojego serwera

## Dodawanie nowych obiektów
Aby dodać nowy prop(obiekt), dodaj go do `Config.Props` w pliku config.lua:
```lua
['nazwa_przedmiotu'] = {
    item = 'nazwa_przedmiotu',
    label = 'Nazwa Wyświetlana',
    model = 'nazwa_modelu',
    animation = {
        dict = 'nazwa_animacji',
        clip = 'nazwa_clipu'
    },
    progressBar = {
        duration = 2000,
        label = 'Nazwa wyświetlana'
    }
}
```

## Licencja
MIT License

## Autor
- MlodyR
- SnailyTeam - FiveM Helper
- SnailyDevelopment - [Discord](https://discord.gg/KCykBSAPsY)

## Wsparcie
W razie problemów lub pytań, utwórz issue na GitHubie lub dołącz do naszego Discorda [Discorda](https://discord.gg/KCykBSAPsY)

``` ```

# Snaily Prop(Object)

Advanced prop placement system.

## Dependencies
- ox_lib
- ox_inventory
- ox_target

## Installation
1. Copy the `snaily-prop` folder to your `resources` directory
2. Add `ensure snaily-prop` to your server.cfg
3. Add items to ox_inventory/data/items.lua:
```lua
['barrier'] = {
    label = 'Barrier',
    weight = 500,
    stack = true,
    close = true,
},
['cone'] = {
    label = 'Cone',
    weight = 500,
    stack = true,
    close = true,
},
```

## Configuration
In `config.lua` you can:
- Adjust movement and rotation speed
- Change animations and their duration
- Add custom props(objects)
- Customize notifications and progress bars for your server

## Adding New Objects
To add a new prop(object), add it to `Config.Props` in config.lua:
```lua
['item_name'] = {
    item = 'item_name',
    label = 'Display Name',
    model = 'model_name',
    animation = {
        dict = 'animation_dict',
        clip = 'animation_clip'
    },
    progressBar = {
        duration = 2000,
        label = 'Display Name'
    }
}
```

## License
MIT License

## Author
- MlodyR
- SnailyTeam - FiveM Helper
- SnailyDevelopment - [Discord](https://discord.gg/KCykBSAPsY)

## Support
If you have any issues or questions, create an issue on GitHub or join our [Discord](https://discord.gg/KCykBSAPsY)
