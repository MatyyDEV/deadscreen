# DeadScreen Script for FiveM 🪦

## Description 📝

The DeadScreen script provides a visual interface for players when they die in-game. It displays a gray screen with a countdown timer until respawn, along with the option to manually respawn by pressing the "E" key. If the player doesn't respawn within the specified time, they will be automatically respawned. ⏳

## Features 🌟

- **Gray Screen Effect**: Displays a gray screen when the player dies. ⚪
- **Countdown Timer**: Shows the time remaining until automatic respawn. ⏰
- **Manual Respawn**: Players can press "E" to respawn immediately. 🔄
- **Automatic Respawn**: If the player does not respawn manually, they will be automatically respawned after the countdown. ⚡

## Installation ⚙️

1. Download the script files.
2. Place the `DeadScreen` folder in your FiveM resources directory.
3. Add `start DeadScreen` to your `server.cfg` file.
4. Restart your server. 🔄

## Configuration ⚙️

- **respawnTime**: Adjust the time (in seconds) for the countdown until automatic respawn. The default is set to 300 seconds (5 minutes). ⏱️

## Usage 🚀

1. When the player’s health drops to zero, the gray screen will appear with a countdown timer. 🕒
2. Press the "E" key to respawn immediately. 🆕
3. If no action is taken, the player will respawn automatically after the countdown. 🔄

## Customization 🎨

You can customize the text colors and font size in the `client.lua` file. Modify the following lines as needed:

```lua
SetTextScale(0.5, 0.5) -- Adjusts text size
SetTextColour(200, 0, 0, 200) -- Adjusts text color (RGBA format)
```

## Issues and Troubleshooting ⚠️

If you encounter any issues with the script:

- Ensure that there are no conflicting scripts affecting player respawn.
- Check the console for any error messages and resolve them accordingly. 🛠️

## License 📜

This script is free to use and modify. Please credit the original author if you make significant changes or use it in your own projects. 🙏

## Contact 📧

For support or inquiries, please contact [Your Name/Your Contact Information]. 💬
