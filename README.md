# MIERDOLO - Arkanoid Clone

A classic Arkanoid/Breakout game built with Godot 4.4 with an epic main menu!

## Features

- **Main Menu**: Animated "MIERDOLO" title with fireworks effects
- Physics-based ball bouncing
- Player-controlled paddle
- Destructible brick grid with multiple colors
- Score tracking and lives system
- Game over and win conditions
- Return to main menu functionality
- Full touch/mobile support

## Controls

### Keyboard
- **Left/Right Arrow Keys**: Move paddle
- **Enter/Space**: Restart game after game over

### Touch/Mobile
- **Tap START GAME button**: Start the game from main menu
- **Left half of screen**: Move paddle left (during gameplay)
- **Right half of screen**: Move paddle right (during gameplay)
- **Tap anywhere**: Return to main menu after game over/win

## Local Development

### Prerequisites
- Godot 4.4.1 or later

### Running Locally
1. Clone the repository
2. Open the project in Godot
3. Press F5 or click "Play" to run the game

## Web Deployment

This project is configured to deploy automatically to Vercel.

### Manual Deployment

1. Install Godot 4.4.1
2. Run the export command:
   ```bash
   godot --headless --export-release "Web" dist/index.html
   ```
3. Deploy the `dist` folder to your web server

### Automatic Deployment with Vercel

1. Connect your GitHub repository to Vercel
2. Set the following environment variables in Vercel:
   - Root directory: `./`
   - Build command: `npm run build`
   - Output directory: `dist`

### GitHub Actions Setup

The workflow will automatically build the project. For automated Vercel deployment, add these secrets to your GitHub repository settings (Settings > Secrets and variables > Actions):

1. **VERCEL_TOKEN**: 
   - Go to https://vercel.com/account/tokens
   - Create a new token
   - Copy the token value

2. **VERCEL_ORG_ID**: 
   - In your Vercel dashboard, go to Settings > General
   - Copy the "Team ID" (for personal accounts, this is your User ID)

3. **VERCEL_PROJECT_ID**: 
   - In your Vercel project dashboard, go to Settings > General  
   - Copy the "Project ID"

**Note**: If these secrets are not configured, the workflow will still build the project and upload the build artifacts, but won't deploy to Vercel automatically.

## Project Structure

- `main.tscn/gd`: Main game scene and logic
- `paddle.tscn/gd`: Player paddle
- `ball.tscn/gd`: Game ball with physics
- `brick.tscn/gd`: Destructible bricks
- `export_presets.cfg`: Godot export configuration
- `vercel.json`: Vercel deployment configuration

## License

MIT License