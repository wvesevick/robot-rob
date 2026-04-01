#!/usr/bin/env python3
"""Generate playful cartoon clue images for all words in GameData.swift."""

from __future__ import annotations

import hashlib
import json
import math
import random
import re
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
GAME_DATA = ROOT / "RobotRobApp" / "Sources" / "GameData.swift"
ASSETS = ROOT / "RobotRobApp" / "Resources" / "Assets.xcassets"
SIZE = 768

WORD_RE = re.compile(r'w\("([a-zA-Z]+)",\s*"([^"]+)"')

CATEGORY_MAP = {
    "animals": {"cat", "dog", "duck", "fish", "bear", "frog", "bee", "ant", "larva", "pupa"},
    "vehicles": {"car", "bus", "bike", "boat", "train", "van"},
    "colors_shapes": {"red", "blue", "green", "star", "heart", "circle"},
    "family": {"mom", "dad", "baby", "hug", "smile", "happy", "adult"},
    "weather": {
        "rain",
        "sunny",
        "cloud",
        "storm",
        "wind",
        "snow",
        "climate",
        "forecast",
        "thunder",
        "breeze",
        "drought",
        "flood",
    },
    "plants": {
        "seed",
        "plant",
        "leaf",
        "flower",
        "root",
        "stem",
        "petal",
        "pollen",
        "sprout",
        "garden",
        "seedling",
        "compost",
        "nature",
    },
    "helpers": {"teacher", "nurse", "doctor", "chef", "pilot", "farmer"},
    "habitats": {
        "nest",
        "pond",
        "cave",
        "den",
        "hive",
        "reef",
        "forest",
        "desert",
        "jungle",
        "tundra",
        "savanna",
        "river",
        "ocean",
        "mountain",
        "valley",
        "canyon",
        "island",
    },
    "space": {"moon", "planet", "comet", "orbit", "rocket"},
    "science": {"light", "sound", "echo", "drum", "bell", "flash", "energy"},
    "senses": {"sight", "smell", "taste", "touch", "ear", "nose"},
    "build": {"bridge", "wheel", "gear", "puzzle", "tower", "block", "motion", "friction"},
    "matter": {"solid", "liquid", "gas", "metal", "wood", "steam"},
    "eco": {"recycle", "reuse"},
    "forces": {"magnet", "gravity", "push", "pull"},
    "lifecycle": {"hatch", "metamorph"},
}


def slug(word: str) -> str:
    return re.sub(r"[^a-z0-9]+", "_", word.lower()).strip("_")


def unique_words() -> list[str]:
    text = GAME_DATA.read_text(encoding="utf-8")
    words = [match.group(1).lower() for match in WORD_RE.finditer(text)]
    seen = set()
    ordered = []
    for word in words:
        if word not in seen:
            ordered.append(word)
            seen.add(word)
    return ordered


def pick_category(word: str) -> str:
    for category, words in CATEGORY_MAP.items():
        if word in words:
            return category
    return "default"


def rand_for_word(word: str) -> random.Random:
    digest = hashlib.sha256(word.encode("utf-8")).hexdigest()
    return random.Random(int(digest[:16], 16))


def rounded_rect(draw: ImageDraw.ImageDraw, box, radius, fill, outline=None, width=1):
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def draw_star(draw: ImageDraw.ImageDraw, center, outer_r, inner_r, points, fill):
    cx, cy = center
    coords = []
    for i in range(points * 2):
        angle = math.pi / 2 + (i * math.pi / points)
        r = outer_r if i % 2 == 0 else inner_r
        coords.append((cx + math.cos(angle) * r, cy - math.sin(angle) * r))
    draw.polygon(coords, fill=fill)


def base_canvas(word: str):
    rng = rand_for_word(word)
    image = Image.new("RGB", (SIZE, SIZE), (255, 255, 255))
    draw = ImageDraw.Draw(image)

    top = (rng.randint(180, 255), rng.randint(180, 255), rng.randint(180, 255))
    bottom = (rng.randint(130, 230), rng.randint(130, 230), rng.randint(130, 230))

    for y in range(SIZE):
        t = y / (SIZE - 1)
        r = int(top[0] * (1 - t) + bottom[0] * t)
        g = int(top[1] * (1 - t) + bottom[1] * t)
        b = int(top[2] * (1 - t) + bottom[2] * t)
        draw.line([(0, y), (SIZE, y)], fill=(r, g, b))

    for _ in range(14):
        x = rng.randint(20, SIZE - 20)
        y = rng.randint(20, SIZE - 20)
        r = rng.randint(12, 34)
        c = (255, 255, 255, 90)
        draw.ellipse((x - r, y - r, x + r, y + r), fill=c)

    rounded_rect(draw, (70, 70, SIZE - 70, SIZE - 70), radius=84, fill=(255, 255, 255), outline=(45, 45, 45), width=6)
    return image, draw


def draw_eyes(draw, cx, cy, spread=70):
    for dx in (-spread // 2, spread // 2):
        draw.ellipse((cx + dx - 18, cy - 16, cx + dx + 18, cy + 20), fill=(255, 255, 255), outline=(40, 40, 40), width=3)
        draw.ellipse((cx + dx - 6, cy - 3, cx + dx + 8, cy + 11), fill=(35, 35, 35))


def draw_animals(draw, word):
    cx, cy = SIZE // 2, 390

    if word == "fish":
        draw.ellipse((cx - 170, cy - 90, cx + 120, cy + 90), fill=(94, 197, 243), outline=(35, 35, 35), width=6)
        draw.polygon([(cx + 120, cy), (cx + 230, cy - 90), (cx + 230, cy + 90)], fill=(65, 163, 216), outline=(35, 35, 35))
        draw.ellipse((cx - 70, cy - 20, cx - 30, cy + 20), fill=(255, 255, 255), outline=(0, 0, 0), width=3)
        draw.ellipse((cx - 56, cy - 6, cx - 42, cy + 8), fill=(0, 0, 0))
        draw.arc((cx - 10, cy + 10, cx + 80, cy + 70), 0, 170, fill=(20, 20, 20), width=5)
        return

    if word == "duck":
        draw.ellipse((cx - 130, cy - 110, cx + 130, cy + 130), fill=(255, 228, 97), outline=(30, 30, 30), width=6)
        draw_eyes(draw, cx, cy - 20, spread=100)
        draw.ellipse((cx - 74, cy + 20, cx + 74, cy + 80), fill=(255, 161, 43), outline=(30, 30, 30), width=5)
        return

    if word == "bee":
        draw.ellipse((cx - 150, cy - 100, cx + 150, cy + 120), fill=(255, 210, 77), outline=(30, 30, 30), width=6)
        for stripe in range(-90, 121, 70):
            draw.rectangle((cx - 150, cy + stripe, cx + 150, cy + stripe + 26), fill=(35, 35, 35))
        draw.ellipse((cx - 220, cy - 80, cx - 120, cy + 10), fill=(220, 246, 255), outline=(70, 90, 110), width=4)
        draw.ellipse((cx + 120, cy - 80, cx + 220, cy + 10), fill=(220, 246, 255), outline=(70, 90, 110), width=4)
        return

    if word == "ant":
        draw.ellipse((cx - 210, cy - 30, cx - 120, cy + 70), fill=(90, 45, 26), outline=(30, 15, 8), width=5)
        draw.ellipse((cx - 100, cy - 55, cx + 35, cy + 90), fill=(95, 50, 28), outline=(30, 15, 8), width=5)
        draw.ellipse((cx + 45, cy - 75, cx + 230, cy + 110), fill=(103, 54, 30), outline=(30, 15, 8), width=5)
        for lx in (-145, -30, 100):
            draw.line((cx + lx, cy + 20, cx + lx - 80, cy + 100), fill=(40, 20, 10), width=6)
            draw.line((cx + lx, cy + 20, cx + lx + 80, cy + 100), fill=(40, 20, 10), width=6)
        return

    if word == "frog":
        face = (96, 202, 104)
    elif word == "bear":
        face = (170, 120, 80)
    elif word == "dog":
        face = (214, 170, 112)
    else:
        face = (245, 171, 103)

    draw.ellipse((cx - 150, cy - 115, cx + 150, cy + 165), fill=face, outline=(35, 35, 35), width=6)

    if word == "bear":
        draw.ellipse((cx - 200, cy - 140, cx - 120, cy - 60), fill=face, outline=(35, 35, 35), width=5)
        draw.ellipse((cx + 120, cy - 140, cx + 200, cy - 60), fill=face, outline=(35, 35, 35), width=5)
    else:
        draw.polygon([(cx - 145, cy - 45), (cx - 72, cy - 170), (cx - 10, cy - 55)], fill=face, outline=(35, 35, 35))
        draw.polygon([(cx + 145, cy - 45), (cx + 72, cy - 170), (cx + 10, cy - 55)], fill=face, outline=(35, 35, 35))

    draw_eyes(draw, cx, cy - 10, spread=110)
    nose = (68, 45, 40)
    draw.ellipse((cx - 28, cy + 35, cx + 28, cy + 72), fill=nose)
    draw.arc((cx - 72, cy + 55, cx + 72, cy + 122), 5, 176, fill=(35, 35, 35), width=5)


def draw_vehicle(draw, word):
    cx, cy = SIZE // 2, 410

    if word == "bike":
        draw.ellipse((cx - 200, cy + 20, cx - 100, cy + 120), outline=(30, 30, 30), width=8)
        draw.ellipse((cx + 100, cy + 20, cx + 200, cy + 120), outline=(30, 30, 30), width=8)
        draw.line((cx - 150, cy + 65, cx - 20, cy + 20), fill=(52, 140, 240), width=8)
        draw.line((cx - 20, cy + 20, cx + 90, cy + 65), fill=(52, 140, 240), width=8)
        draw.line((cx - 20, cy + 20, cx + 20, cy + 90), fill=(52, 140, 240), width=8)
        draw.line((cx + 20, cy + 90, cx - 150, cy + 65), fill=(52, 140, 240), width=8)
        draw.line((cx + 90, cy + 65, cx + 120, cy - 10), fill=(52, 140, 240), width=8)
        return

    if word == "boat":
        draw.polygon([(cx - 220, cy + 95), (cx + 220, cy + 95), (cx + 160, cy + 165), (cx - 160, cy + 165)], fill=(62, 117, 182), outline=(35, 35, 35))
        draw.polygon([(cx, cy - 180), (cx, cy + 95), (cx + 155, cy + 35)], fill=(255, 228, 116), outline=(35, 35, 35))
        draw.rectangle((cx - 4, cy - 200, cx + 6, cy + 95), fill=(55, 40, 30))
        draw.arc((cx - 260, cy + 125, cx - 120, cy + 200), 200, 340, fill=(70, 160, 240), width=8)
        draw.arc((cx - 50, cy + 125, cx + 90, cy + 200), 200, 340, fill=(70, 160, 240), width=8)
        return

    if word == "train":
        draw.rounded_rectangle((cx - 230, cy - 50, cx + 220, cy + 150), radius=35, fill=(237, 74, 72), outline=(35, 35, 35), width=6)
        draw.rectangle((cx - 190, cy - 130, cx + 20, cy - 50), fill=(247, 182, 82), outline=(35, 35, 35), width=5)
        draw.ellipse((cx + 65, cy - 120, cx + 150, cy - 45), fill=(239, 95, 40), outline=(35, 35, 35), width=5)
    else:
        base = {
            "car": (250, 102, 71),
            "bus": (252, 199, 56),
            "van": (98, 170, 250),
        }.get(word, (250, 102, 71))
        draw.rounded_rectangle((cx - 240, cy - 30, cx + 240, cy + 140), radius=45, fill=base, outline=(35, 35, 35), width=6)
        draw.rectangle((cx - 180, cy - 90, cx + 90, cy - 30), fill=(212, 241, 255), outline=(35, 35, 35), width=5)

    draw.ellipse((cx - 180, cy + 112, cx - 95, cy + 197), fill=(35, 35, 35))
    draw.ellipse((cx + 90, cy + 112, cx + 175, cy + 197), fill=(35, 35, 35))


def draw_color_shape(draw, word):
    cx, cy = SIZE // 2, 390
    if word in {"red", "blue", "green"}:
        palette = {
            "red": (239, 74, 74),
            "blue": (85, 142, 236),
            "green": (78, 189, 102),
        }
        color = palette[word]
        draw.ellipse((cx - 160, cy - 100, cx + 160, cy + 160), fill=color, outline=(30, 30, 30), width=6)
        for i in range(5):
            x = cx - 110 + i * 56
            draw.ellipse((x, cy + 130, x + 24, cy + 185), fill=color, outline=(30, 30, 30), width=3)
        return

    if word == "star":
        draw_star(draw, (cx, cy + 20), 190, 82, 5, (255, 208, 64))
        draw.ellipse((cx - 38, cy - 5, cx + 38, cy + 72), fill=(255, 235, 113), outline=(50, 40, 20), width=4)
        return

    if word == "heart":
        draw.polygon([(cx, cy + 200), (cx - 210, cy - 20), (cx - 130, cy - 150), (cx, cy - 70), (cx + 130, cy - 150), (cx + 210, cy - 20)], fill=(250, 91, 113), outline=(40, 20, 30))
        return

    draw.ellipse((cx - 190, cy - 160, cx + 190, cy + 220), fill=(143, 197, 255), outline=(30, 30, 30), width=6)


def draw_family(draw, word):
    cx, cy = SIZE // 2, 390
    draw.ellipse((cx - 170, cy - 70, cx - 30, cy + 70), fill=(254, 218, 170), outline=(40, 40, 40), width=4)
    draw.ellipse((cx + 30, cy - 70, cx + 170, cy + 70), fill=(254, 218, 170), outline=(40, 40, 40), width=4)
    draw.ellipse((cx - 125, cy - 95, cx - 70, cy - 35), fill=(35, 35, 35))
    draw.ellipse((cx + 70, cy - 95, cx + 125, cy - 35), fill=(35, 35, 35))
    draw_eyes(draw, cx - 100, cy - 5, spread=52)
    draw_eyes(draw, cx + 100, cy - 5, spread=52)
    draw.arc((cx - 132, cy + 28, cx - 66, cy + 70), 5, 176, fill=(40, 40, 40), width=4)
    draw.arc((cx + 66, cy + 28, cx + 132, cy + 70), 5, 176, fill=(40, 40, 40), width=4)
    draw.ellipse((cx - 44, cy + 66, cx + 44, cy + 152), fill=(250, 105, 130), outline=(40, 30, 30), width=4)

    if word == "baby":
        draw.ellipse((cx - 66, cy + 120, cx + 66, cy + 244), fill=(197, 228, 255), outline=(45, 45, 45), width=4)
    elif word in {"hug", "smile", "happy"}:
        draw.arc((cx - 210, cy + 50, cx + 210, cy + 230), 200, 340, fill=(247, 94, 120), width=7)


def draw_weather(draw, word):
    cx, cy = SIZE // 2, 360

    draw.ellipse((cx - 190, cy - 50, cx + 190, cy + 170), fill=(225, 239, 252), outline=(40, 60, 85), width=5)
    draw.ellipse((cx - 270, cy + 15, cx - 80, cy + 170), fill=(236, 247, 255), outline=(40, 60, 85), width=5)
    draw.ellipse((cx + 80, cy + 15, cx + 270, cy + 170), fill=(236, 247, 255), outline=(40, 60, 85), width=5)

    if word in {"sunny", "drought", "climate", "forecast"}:
        draw.ellipse((cx - 110, cy - 180, cx + 110, cy + 40), fill=(255, 205, 63), outline=(80, 60, 20), width=6)
        for i in range(12):
            ang = i * math.pi / 6
            draw.line(
                (cx + math.cos(ang) * 140, cy - 70 + math.sin(ang) * 140, cx + math.cos(ang) * 190, cy - 70 + math.sin(ang) * 190),
                fill=(255, 190, 52),
                width=7,
            )

    if word in {"rain", "storm", "flood"}:
        for x in range(cx - 150, cx + 170, 55):
            draw.polygon([(x, cy + 165), (x + 18, cy + 220), (x - 18, cy + 220)], fill=(74, 154, 240))

    if word in {"snow"}:
        for x in range(cx - 155, cx + 170, 70):
            for y in (cy + 188, cy + 238):
                draw.line((x - 16, y, x + 16, y), fill=(120, 170, 220), width=3)
                draw.line((x, y - 16, x, y + 16), fill=(120, 170, 220), width=3)

    if word in {"thunder", "storm"}:
        draw.polygon([(cx + 80, cy + 130), (cx + 20, cy + 240), (cx + 95, cy + 240), (cx + 25, cy + 360)], fill=(254, 219, 64), outline=(90, 80, 30))

    if word in {"wind", "breeze"}:
        for y in (cy + 205, cy + 245, cy + 285):
            draw.arc((cx - 250, y - 45, cx + 190, y + 45), 0, 170, fill=(120, 160, 210), width=7)


def draw_plants(draw, word):
    cx, cy = SIZE // 2, 430
    draw.ellipse((cx - 200, cy + 100, cx + 200, cy + 220), fill=(151, 95, 58), outline=(50, 30, 15), width=5)

    if word in {"seed", "pollen"}:
        for i in range(-4, 5):
            draw.ellipse((cx + i * 42 - 14, cy + 60, cx + i * 42 + 14, cy + 90), fill=(246, 199, 92), outline=(70, 50, 20))

    stem_color = (72, 168, 85)
    draw.rectangle((cx - 12, cy - 120, cx + 12, cy + 110), fill=stem_color)
    draw.ellipse((cx - 130, cy - 30, cx - 20, cy + 50), fill=(96, 187, 110), outline=(40, 90, 50), width=4)
    draw.ellipse((cx + 20, cy - 80, cx + 130, cy + 0), fill=(96, 187, 110), outline=(40, 90, 50), width=4)

    if word in {"flower", "petal"}:
        petal = (252, 124, 159)
        for i in range(8):
            angle = i * math.pi / 4
            x = cx + math.cos(angle) * 68
            y = cy - 140 + math.sin(angle) * 68
            draw.ellipse((x - 40, y - 30, x + 40, y + 30), fill=petal, outline=(90, 40, 60), width=3)
        draw.ellipse((cx - 34, cy - 174, cx + 34, cy - 106), fill=(255, 222, 109), outline=(90, 80, 30), width=3)
    elif word in {"root"}:
        for i in (-40, -10, 20, 50):
            draw.line((cx, cy + 102, cx + i, cy + 178), fill=(113, 69, 39), width=5)


def draw_helpers(draw, word):
    cx, cy = SIZE // 2, 392
    draw.ellipse((cx - 100, cy - 180, cx + 100, cy - 20), fill=(255, 222, 179), outline=(45, 45, 45), width=5)
    draw_eyes(draw, cx, cy - 110, spread=90)
    draw.arc((cx - 55, cy - 65, cx + 55, cy - 20), 5, 175, fill=(35, 35, 35), width=4)
    outfit = {
        "teacher": (95, 154, 248),
        "nurse": (255, 122, 132),
        "doctor": (240, 242, 244),
        "chef": (255, 218, 105),
        "pilot": (80, 114, 168),
        "farmer": (99, 184, 98),
    }.get(word, (116, 166, 235))
    draw.rounded_rectangle((cx - 150, cy - 20, cx + 150, cy + 230), radius=60, fill=outfit, outline=(40, 40, 40), width=5)
    if word in {"doctor", "nurse"}:
        draw.arc((cx - 70, cy + 30, cx + 70, cy + 180), 180, 360, fill=(65, 65, 65), width=7)
    if word == "chef":
        draw.rectangle((cx - 75, cy - 245, cx + 75, cy - 175), fill=(255, 255, 255), outline=(35, 35, 35), width=4)
        draw.ellipse((cx - 110, cy - 278, cx + 110, cy - 185), fill=(255, 255, 255), outline=(35, 35, 35), width=4)


def draw_habitat(draw, word):
    cx, cy = SIZE // 2, 420
    draw.rectangle((120, cy + 90, SIZE - 120, SIZE - 130), fill=(104, 189, 105))
    draw.polygon([(120, cy + 90), (SIZE - 120, cy + 90), (SIZE - 120, cy + 20), (120, cy + 20)], fill=(109, 189, 246))

    if word in {"mountain", "valley", "canyon", "cave", "den", "tundra", "desert"}:
        draw.polygon([(170, cy + 90), (320, cy - 180), (470, cy + 90)], fill=(149, 122, 109), outline=(40, 40, 40))
        draw.polygon([(350, cy + 90), (520, cy - 110), (680, cy + 90)], fill=(170, 145, 124), outline=(40, 40, 40))
        if word in {"tundra"}:
            draw.polygon([(280, cy - 110), (320, cy - 180), (360, cy - 110)], fill=(235, 245, 250))
    if word in {"forest", "jungle", "savanna", "nest", "hive"}:
        draw.rectangle((230, cy - 70, 260, cy + 120), fill=(111, 71, 46))
        draw.ellipse((165, cy - 170, 325, cy - 15), fill=(63, 160, 84), outline=(35, 35, 35), width=4)
        draw.rectangle((500, cy - 40, 528, cy + 120), fill=(111, 71, 46))
        draw.ellipse((430, cy - 130, 600, cy + 5), fill=(82, 180, 95), outline=(35, 35, 35), width=4)
    if word in {"river", "ocean", "pond", "reef", "island"}:
        draw.arc((130, cy + 50, SIZE - 130, SIZE - 70), 190, 345, fill=(66, 156, 237), width=14)


def draw_space(draw, word):
    cx, cy = SIZE // 2, 400
    draw.rectangle((125, 125, SIZE - 125, SIZE - 125), fill=(26, 33, 88), outline=(34, 40, 95), width=0)
    rng = rand_for_word(word)
    for _ in range(40):
        x = rng.randint(145, SIZE - 145)
        y = rng.randint(145, SIZE - 145)
        r = rng.randint(2, 6)
        draw.ellipse((x - r, y - r, x + r, y + r), fill=(250, 250, 230))

    if word == "rocket":
        draw.polygon([(cx, cy - 180), (cx - 70, cy + 20), (cx + 70, cy + 20)], fill=(239, 92, 84), outline=(20, 20, 20))
        draw.rounded_rectangle((cx - 70, cy + 20, cx + 70, cy + 220), radius=30, fill=(240, 245, 250), outline=(20, 20, 20), width=4)
        draw.ellipse((cx - 28, cy + 60, cx + 28, cy + 116), fill=(127, 190, 250), outline=(20, 20, 20), width=3)
        draw.polygon([(cx - 70, cy + 130), (cx - 145, cy + 210), (cx - 70, cy + 210)], fill=(255, 173, 67), outline=(20, 20, 20))
        draw.polygon([(cx + 70, cy + 130), (cx + 145, cy + 210), (cx + 70, cy + 210)], fill=(255, 173, 67), outline=(20, 20, 20))
        return

    if word == "comet":
        draw.ellipse((cx + 30, cy - 60, cx + 170, cy + 80), fill=(255, 223, 143), outline=(30, 30, 30), width=4)
        draw.polygon([(cx - 220, cy - 10), (cx + 30, cy - 60), (cx + 20, cy + 80)], fill=(149, 212, 255), outline=(30, 30, 30))
        return

    if word == "moon":
        draw.ellipse((cx - 180, cy - 140, cx + 180, cy + 220), fill=(240, 225, 171), outline=(20, 20, 20), width=4)
        draw.ellipse((cx - 90, cy - 70, cx + 250, cy + 230), fill=(26, 33, 88))
        return

    draw.ellipse((cx - 170, cy - 130, cx + 170, cy + 210), fill=(90, 162, 242), outline=(20, 20, 20), width=4)
    draw.arc((cx - 240, cy - 180, cx + 240, cy + 240), 15, 165, fill=(247, 227, 124), width=12)


def draw_science(draw, word):
    cx, cy = SIZE // 2, 400
    if word == "light":
        draw.ellipse((cx - 120, cy - 180, cx + 120, cy + 40), fill=(255, 226, 103), outline=(50, 45, 20), width=6)
        draw.rectangle((cx - 50, cy + 40, cx + 50, cy + 150), fill=(109, 111, 126), outline=(40, 40, 40), width=5)
        return
    if word in {"drum", "sound", "echo", "bell", "flash"}:
        draw.ellipse((cx - 200, cy - 40, cx + 200, cy + 90), fill=(250, 145, 110), outline=(35, 35, 35), width=6)
        draw.ellipse((cx - 200, cy + 30, cx + 200, cy + 160), fill=(234, 106, 89), outline=(35, 35, 35), width=6)
        draw.line((cx - 140, cy - 130, cx - 30, cy + 10), fill=(114, 78, 53), width=13)
        draw.line((cx + 140, cy - 130, cx + 30, cy + 10), fill=(114, 78, 53), width=13)
        for i in range(3):
            draw.arc((cx + 140 + i * 25, cy - 70 - i * 25, cx + 250 + i * 25, cy + 40 + i * 25), 260, 80, fill=(76, 152, 227), width=6)
        return
    draw.polygon([(cx - 120, cy + 160), (cx + 120, cy + 160), (cx + 50, cy + 20), (cx - 50, cy + 20)], fill=(102, 180, 255), outline=(35, 35, 35), width=5)
    draw.rectangle((cx - 22, cy - 100, cx + 22, cy + 20), fill=(70, 70, 70))
    draw.ellipse((cx - 130, cy - 210, cx + 130, cy - 80), fill=(255, 221, 116), outline=(50, 40, 20), width=5)


def draw_senses(draw, word):
    cx, cy = SIZE // 2, 400
    if word in {"ear"}:
        draw.arc((cx - 140, cy - 160, cx + 140, cy + 170), 50, 320, fill=(250, 196, 153), width=35)
        draw.arc((cx - 70, cy - 40, cx + 55, cy + 130), 60, 310, fill=(205, 136, 100), width=18)
        return
    if word in {"nose", "smell"}:
        draw.polygon([(cx, cy - 180), (cx - 80, cy + 100), (cx + 80, cy + 100)], fill=(249, 201, 166), outline=(35, 35, 35))
        draw.ellipse((cx - 80, cy + 80, cx - 10, cy + 145), fill=(235, 171, 130), outline=(70, 50, 40))
        draw.ellipse((cx + 10, cy + 80, cx + 80, cy + 145), fill=(235, 171, 130), outline=(70, 50, 40))
        return
    if word in {"sight"}:
        draw.ellipse((cx - 220, cy - 70, cx + 220, cy + 170), fill=(255, 255, 255), outline=(30, 30, 30), width=6)
        draw.ellipse((cx - 90, cy - 20, cx + 90, cy + 140), fill=(130, 181, 237), outline=(30, 30, 30), width=5)
        draw.ellipse((cx - 30, cy + 20, cx + 30, cy + 80), fill=(25, 25, 25))
        return
    if word in {"touch"}:
        draw.rounded_rectangle((cx - 130, cy - 170, cx + 130, cy + 180), radius=60, fill=(246, 192, 144), outline=(35, 35, 35), width=5)
        for i in range(-2, 3):
            draw.rectangle((cx - 140 + i * 55, cy - 205, cx - 100 + i * 55, cy - 50), fill=(246, 192, 144), outline=(35, 35, 35), width=4)
        return
    draw.ellipse((cx - 210, cy - 40, cx + 210, cy + 120), fill=(255, 151, 165), outline=(30, 30, 30), width=5)
    draw.polygon([(cx - 80, cy + 40), (cx + 80, cy + 40), (cx, cy + 220)], fill=(241, 92, 114), outline=(30, 30, 30))


def draw_build(draw, word):
    cx, cy = SIZE // 2, 420
    if word == "gear":
        for i in range(12):
            angle = i * math.pi / 6
            x1 = cx + math.cos(angle) * 160
            y1 = cy + math.sin(angle) * 160
            x2 = cx + math.cos(angle) * 215
            y2 = cy + math.sin(angle) * 215
            draw.line((x1, y1, x2, y2), fill=(115, 132, 155), width=18)
        draw.ellipse((cx - 170, cy - 170, cx + 170, cy + 170), fill=(151, 172, 196), outline=(35, 35, 35), width=6)
        draw.ellipse((cx - 65, cy - 65, cx + 65, cy + 65), fill=(236, 245, 250), outline=(35, 35, 35), width=5)
        return
    if word in {"wheel"}:
        draw.ellipse((cx - 200, cy - 200, cx + 200, cy + 200), fill=(55, 55, 55), outline=(20, 20, 20), width=6)
        draw.ellipse((cx - 130, cy - 130, cx + 130, cy + 130), fill=(170, 178, 190), outline=(45, 45, 45), width=5)
        for i in range(8):
            a = i * math.pi / 4
            draw.line((cx, cy, cx + math.cos(a) * 115, cy + math.sin(a) * 115), fill=(70, 70, 70), width=6)
        return
    if word in {"puzzle"}:
        draw.rounded_rectangle((cx - 190, cy - 170, cx + 190, cy + 170), radius=70, fill=(252, 206, 83), outline=(40, 40, 40), width=6)
        draw.ellipse((cx - 35, cy - 225, cx + 35, cy - 155), fill=(252, 206, 83), outline=(40, 40, 40), width=6)
        draw.ellipse((cx - 35, cy + 155, cx + 35, cy + 225), fill=(252, 206, 83), outline=(40, 40, 40), width=6)
        draw.ellipse((cx - 225, cy - 35, cx - 155, cy + 35), fill=(252, 206, 83), outline=(40, 40, 40), width=6)
        draw.ellipse((cx + 155, cy - 35, cx + 225, cy + 35), fill=(252, 206, 83), outline=(40, 40, 40), width=6)
        return
    if word in {"tower", "block", "bridge"}:
        draw.rectangle((cx - 200, cy + 30, cx + 200, cy + 210), fill=(174, 124, 94), outline=(40, 40, 40), width=5)
        draw.rectangle((cx - 170, cy - 70, cx - 30, cy + 30), fill=(230, 167, 117), outline=(40, 40, 40), width=5)
        draw.rectangle((cx + 30, cy - 145, cx + 170, cy + 30), fill=(245, 190, 128), outline=(40, 40, 40), width=5)
        return
    for i in range(6):
        draw.arc((cx - 220 + i * 20, cy - 130 + i * 14, cx + 220 + i * 20, cy + 130 + i * 14), 200, 330, fill=(84, 163, 240), width=8)


def draw_matter(draw, word):
    cx, cy = SIZE // 2, 400
    if word == "solid":
        draw.polygon([(cx, cy - 170), (cx - 150, cy - 90), (cx - 150, cy + 95), (cx, cy + 175), (cx + 150, cy + 95), (cx + 150, cy - 90)], fill=(102, 182, 248), outline=(35, 35, 35))
        return
    if word == "liquid":
        draw.polygon([(cx, cy - 180), (cx - 120, cy + 110), (cx + 120, cy + 110)], fill=(79, 165, 245), outline=(35, 35, 35))
        return
    if word in {"gas", "steam"}:
        for i in range(4):
            draw.arc((cx - 170 + i * 60, cy - 120 - i * 22, cx - 20 + i * 60, cy + 70 - i * 22), 20, 280, fill=(180, 188, 202), width=10)
        return
    if word == "metal":
        draw.rounded_rectangle((cx - 180, cy - 60, cx + 180, cy + 120), radius=34, fill=(164, 177, 196), outline=(50, 50, 50), width=5)
        draw.rectangle((cx - 120, cy - 30, cx + 120, cy + 0), fill=(205, 215, 230))
        return
    draw.rounded_rectangle((cx - 200, cy - 120, cx + 200, cy + 150), radius=30, fill=(156, 106, 72), outline=(50, 35, 20), width=6)
    for i in range(-2, 3):
        draw.line((cx - 170, cy - 80 + i * 48, cx + 170, cy - 65 + i * 48), fill=(124, 79, 51), width=4)


def draw_eco(draw, word):
    cx, cy = SIZE // 2, 400
    for i in range(3):
        angle = i * (2 * math.pi / 3) - math.pi / 6
        x1, y1 = cx + math.cos(angle) * 170, cy + math.sin(angle) * 170
        x2, y2 = cx + math.cos(angle + 0.8) * 170, cy + math.sin(angle + 0.8) * 170
        xm, ym = cx + math.cos(angle + 0.4) * 240, cy + math.sin(angle + 0.4) * 240
        draw.polygon([(x1, y1), (x2, y2), (xm, ym)], fill=(84, 184, 98), outline=(35, 35, 35))

    if word == "reuse":
        draw.rounded_rectangle((cx - 105, cy - 80, cx + 105, cy + 120), radius=22, fill=(236, 245, 250), outline=(35, 35, 35), width=5)
        draw.rectangle((cx - 28, cy - 120, cx + 28, cy - 80), fill=(130, 145, 165), outline=(35, 35, 35), width=4)


def draw_forces(draw, word):
    cx, cy = SIZE // 2, 400
    if word == "magnet":
        draw.arc((cx - 190, cy - 160, cx + 190, cy + 220), 200, 340, fill=(229, 72, 73), width=88)
        draw.rectangle((cx - 190, cy + 15, cx - 115, cy + 125), fill=(214, 222, 230))
        draw.rectangle((cx + 115, cy + 15, cx + 190, cy + 125), fill=(214, 222, 230))
        return
    if word == "gravity":
        draw.ellipse((cx - 180, cy - 130, cx + 180, cy + 230), fill=(101, 165, 244), outline=(35, 35, 35), width=5)
        draw.polygon([(cx + 150, cy - 190), (cx + 95, cy - 80), (cx + 205, cy - 80)], fill=(250, 98, 90), outline=(35, 35, 35))
        return
    arrow_color = (93, 163, 245)
    draw.rounded_rectangle((cx - 180, cy - 50, cx + 180, cy + 70), radius=40, fill=(214, 229, 245), outline=(40, 40, 40), width=5)
    if word == "push":
        draw.polygon([(cx + 170, cy + 10), (cx + 80, cy - 70), (cx + 80, cy + 90)], fill=arrow_color, outline=(40, 40, 40))
        draw.rounded_rectangle((cx - 200, cy - 20, cx - 80, cy + 40), radius=20, fill=(250, 180, 86), outline=(40, 40, 40), width=4)
    else:
        draw.polygon([(cx - 170, cy + 10), (cx - 80, cy - 70), (cx - 80, cy + 90)], fill=arrow_color, outline=(40, 40, 40))
        draw.rounded_rectangle((cx + 80, cy - 20, cx + 200, cy + 40), radius=20, fill=(250, 180, 86), outline=(40, 40, 40), width=4)


def draw_lifecycle(draw, word):
    cx, cy = SIZE // 2, 410
    if word == "hatch":
        draw.ellipse((cx - 150, cy - 130, cx + 150, cy + 180), fill=(245, 239, 223), outline=(50, 50, 50), width=6)
        draw.line((cx - 40, cy + 20, cx + 20, cy - 40), fill=(60, 60, 60), width=4)
        draw.line((cx + 20, cy - 40, cx + 80, cy + 30), fill=(60, 60, 60), width=4)
        draw.line((cx - 20, cy + 60, cx + 40, cy + 0), fill=(60, 60, 60), width=4)
        return

    # metamorph
    for s in (-1, 1):
        draw.ellipse((cx + s * 180 - 190, cy - 120, cx + s * 180 + 20, cy + 120), fill=(251, 159, 79), outline=(40, 40, 40), width=5)
        draw.ellipse((cx + s * 180 - 140, cy - 160, cx + s * 180 + 40, cy + 70), fill=(252, 211, 99), outline=(40, 40, 40), width=5)
    draw.rectangle((cx - 25, cy - 130, cx + 25, cy + 140), fill=(65, 65, 65))
    draw.line((cx - 10, cy - 130, cx - 50, cy - 190), fill=(65, 65, 65), width=4)
    draw.line((cx + 10, cy - 130, cx + 50, cy - 190), fill=(65, 65, 65), width=4)


def draw_default(draw, word):
    cx, cy = SIZE // 2, 400
    rounded_rect(draw, (cx - 170, cy - 170, cx + 170, cy + 170), radius=64, fill=(250, 221, 114), outline=(40, 40, 40), width=6)
    draw_eyes(draw, cx, cy - 40, spread=120)
    draw.line((cx - 90, cy + 70, cx + 90, cy + 70), fill=(45, 45, 45), width=6)


def draw_word_image(word: str) -> Image.Image:
    image, draw = base_canvas(word)
    category = pick_category(word)

    if category == "animals":
        draw_animals(draw, word)
    elif category == "vehicles":
        draw_vehicle(draw, word)
    elif category == "colors_shapes":
        draw_color_shape(draw, word)
    elif category == "family":
        draw_family(draw, word)
    elif category == "weather":
        draw_weather(draw, word)
    elif category == "plants":
        draw_plants(draw, word)
    elif category == "helpers":
        draw_helpers(draw, word)
    elif category == "habitats":
        draw_habitat(draw, word)
    elif category == "space":
        draw_space(draw, word)
    elif category == "science":
        draw_science(draw, word)
    elif category == "senses":
        draw_senses(draw, word)
    elif category == "build":
        draw_build(draw, word)
    elif category == "matter":
        draw_matter(draw, word)
    elif category == "eco":
        draw_eco(draw, word)
    elif category == "forces":
        draw_forces(draw, word)
    elif category == "lifecycle":
        draw_lifecycle(draw, word)
    else:
        draw_default(draw, word)

    rounded_rect(draw, (95, 95, SIZE - 95, SIZE - 95), radius=74, fill=None, outline=(255, 255, 255), width=5)
    return image


def write_imageset(asset_name: str, image: Image.Image):
    imageset_dir = ASSETS / f"{asset_name}.imageset"
    imageset_dir.mkdir(parents=True, exist_ok=True)

    filename = f"{asset_name}.png"
    image.save(imageset_dir / filename, format="PNG")

    contents = {
        "images": [
            {
                "filename": filename,
                "idiom": "universal",
                "scale": "1x",
            },
            {
                "idiom": "universal",
                "scale": "2x",
            },
            {
                "idiom": "universal",
                "scale": "3x",
            },
        ],
        "info": {"author": "xcode", "version": 1},
    }

    (imageset_dir / "Contents.json").write_text(json.dumps(contents, indent=2) + "\n", encoding="utf-8")


def main():
    words = unique_words()
    generated = 0

    for word in words:
        asset_name = f"clue_{slug(word)}"
        image = draw_word_image(word)
        write_imageset(asset_name, image)
        generated += 1

    print(f"Generated {generated} clue images in {ASSETS}")


if __name__ == "__main__":
    main()
