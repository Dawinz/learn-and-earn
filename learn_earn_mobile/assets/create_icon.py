#!/usr/bin/env python3
"""
Create a professional app icon for Learn & Earn
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_app_icon():
    # Create a 1024x1024 image with a blue gradient background
    size = 1024
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Create gradient background (blue to darker blue)
    for y in range(size):
        # Calculate gradient from light blue to dark blue
        r = int(33 + (25 - 33) * y / size)  # 33 to 25
        g = int(150 + (118 - 150) * y / size)  # 150 to 118  
        b = int(243 + (210 - 243) * y / size)  # 243 to 210
        draw.line([(0, y), (size, y)], fill=(r, g, b, 255))
    
    # Add rounded corners
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([0, 0, size, size], radius=200, fill=255)
    
    # Apply mask
    img.putalpha(mask)
    
    # Draw book icon (left side)
    book_x, book_y = 200, 300
    book_width, book_height = 200, 280
    
    # Book base
    draw.rounded_rectangle(
        [book_x, book_y, book_x + book_width, book_y + book_height],
        radius=20, fill=(255, 255, 255, 230)
    )
    
    # Book pages (lines)
    for i, line_width in enumerate([140, 120, 130, 110, 125, 115, 135, 105, 120, 130, 100, 125]):
        y_pos = book_y + 40 + i * 20
        x_pos = book_x + 30
        draw.rounded_rectangle(
            [x_pos, y_pos, x_pos + line_width, y_pos + 8],
            radius=4, fill=(33, 150, 243, 180)
        )
    
    # Draw coin icon (right side)
    coin_x, coin_y = 600, 200
    coin_radius = 80
    
    # Coin shadow
    draw.ellipse(
        [coin_x - coin_radius + 5, coin_y - coin_radius + 5, 
         coin_x + coin_radius + 5, coin_y + coin_radius + 5],
        fill=(255, 160, 0, 100)
    )
    
    # Coin base
    draw.ellipse(
        [coin_x - coin_radius, coin_y - coin_radius, 
         coin_x + coin_radius, coin_y + coin_radius],
        fill=(255, 215, 0, 255)
    )
    
    # Coin border
    draw.ellipse(
        [coin_x - coin_radius, coin_y - coin_radius, 
         coin_x + coin_radius, coin_y + coin_radius],
        outline=(255, 160, 0, 255), width=6
    )
    
    # Dollar sign on coin
    try:
        # Try to use a system font
        font_size = 60
        font = ImageFont.truetype("/System/Library/Fonts/Arial.ttf", font_size)
    except:
        try:
            font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", font_size)
        except:
            font = ImageFont.load_default()
    
    # Get text size for centering
    bbox = draw.textbbox((0, 0), "$", font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    # Draw dollar sign
    draw.text(
        (coin_x - text_width//2, coin_y - text_height//2 + 10),
        "$", fill=(255, 160, 0, 255), font=font
    )
    
    # Coin shine effect
    draw.ellipse(
        [coin_x - 25, coin_y - 45, coin_x + 5, coin_y - 15],
        fill=(255, 255, 255, 100)
    )
    
    # Plus sign in center
    plus_x, plus_y = 480, 480
    plus_size = 40
    
    # Plus background circle
    draw.ellipse(
        [plus_x - plus_size, plus_y - plus_size, 
         plus_x + plus_size, plus_y + plus_size],
        fill=(255, 255, 255, 230)
    )
    
    # Plus sign
    draw.rectangle(
        [plus_x - 12, plus_y - 4, plus_x + 12, plus_y + 4],
        fill=(33, 150, 243, 255)
    )
    draw.rectangle(
        [plus_x - 4, plus_y - 12, plus_x + 4, plus_y + 12],
        fill=(33, 150, 243, 255)
    )
    
    # Add some decorative dots
    dots = [(150, 150, 8), (850, 200, 6), (200, 800, 10), (800, 750, 7)]
    for x, y, radius in dots:
        draw.ellipse(
            [x - radius, y - radius, x + radius, y + radius],
            fill=(255, 255, 255, 150)
        )
    
    return img

if __name__ == "__main__":
    # Create the icon
    icon = create_app_icon()
    
    # Save as PNG
    icon.save("assets/app_icon.png", "PNG")
    print("App icon created successfully: assets/app_icon.png")
    
    # Also create a smaller version for preview
    preview = icon.resize((256, 256), Image.Resampling.LANCZOS)
    preview.save("assets/app_icon_preview.png", "PNG")
    print("Preview icon created: assets/app_icon_preview.png")

