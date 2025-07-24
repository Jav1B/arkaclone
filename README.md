# Arkanoid Clone

A classic Arkanoid/Breakout game built with Godot 4.4.

## Features

- Physics-based ball bouncing
- Player-controlled paddle
- Destructible brick grid with multiple colors
- Score tracking and lives system
- Game over and win conditions
- Restart functionality

## Controls

- **Left/Right Arrow Keys**: Move paddle
- **Enter/Space**: Restart game after game over

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

For automated builds, add these secrets to your GitHub repository:
- `VERCEL_TOKEN`: Your Vercel token
- `VERCEL_ORG_ID`: Your Vercel organization ID  
- `VERCEL_PROJECT_ID`: Your Vercel project ID

## Project Structure

- `main.tscn/gd`: Main game scene and logic
- `paddle.tscn/gd`: Player paddle
- `ball.tscn/gd`: Game ball with physics
- `brick.tscn/gd`: Destructible bricks
- `export_presets.cfg`: Godot export configuration
- `vercel.json`: Vercel deployment configuration

## License

MIT License