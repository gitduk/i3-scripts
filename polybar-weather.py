import os
import argparse
import requests

# Get your API KEY here https://openweathermap.org/api,
# and set an environment variable for OPENWEATHER_API_KEY with your API KEY.
OPENWEATHER_URL = "https://api.openweathermap.org/data/2.5/weather"
OPENWEATHER_API_KEY = "970606528befaa317698cc75083db8b2"
USAGE_MESSAGE = f"""%(prog)s [-c [CITY_NAME]] [-u [UNIT]] [-a [API_KEY]] [-l [LANGUAGE]] [-v]

Some examples:
~$ %(prog)s
::> 275 K

~$ %(prog)s -c london
::> 291 K

~$ %(prog)s -u imperial -v
::> 79ºF, Scattered Clouds

~$ %(prog)s -v -C -u metric
::> 26ºC, Broken Clouds

~$ %(prog)s -c florida -u metric -v
::> 27ºC, Thunderstorm

~$ %(prog)s -c rio de janeiro -u metric -a 439d4b804bc8187953eb36d2a8c26a02 -v -l pt_br
::> 25ºC, Céu Limpo
"""


def get_weather(city: str, lang: str, unit: str, api_key: str):
    try:
        r = requests.get(
            f"{OPENWEATHER_URL}?q={city}&lang={lang}&units={unit}&appid={api_key}",
            headers={"User-agent": "Mozilla/5.0"},
        )
        data = r.json()
        temp = data.get("main").get("temp")
        desc = data.get("weather")[0].get("description")
        unit = unit_suffix(unit)

        return {
            "temp": f"{int(temp)}{unit}",
            "desc": desc.title(),
        }
    except Exception:
        return None

def format_city(city: list[str]) -> str:
    return "+".join(city).title()


def get_city() -> str:
    try:
        r = requests.get("https://ipapi.co/json", headers={"User-agent": "Mozilla/5.0"})
        return r.json()["city"]
    except Exception:
        return "london"

def get_args():
    parser = argparse.ArgumentParser(
    usage=USAGE_MESSAGE,
    description="Display information about the weather.",
    )
    parser.add_argument(
        "-c",
        metavar="CITY",
        dest="city",
        type=str,
        nargs="+",
        help="city name",
    )
    parser.add_argument(
        "-l",
        metavar="LANG",
        dest="lang",
        type=str,
        nargs=1,
        help="language (en, es, fr, ja, pt, pt_br, ru, zh_cn)",
    )
    parser.add_argument(
        "-u",
        metavar="metric/imperial",
        choices=("metric", "imperial"),
        dest="unit",
        type=str,
        nargs=1,
        help="unit of temperature (default: kelvin)",
    )
    parser.add_argument(
        "-a",
        metavar="API_KEY",
        dest="api_key",
        nargs=1,
        help="API Key",
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        dest="verbose",
        help="verbose mode",
    )

    return parser.parse_args()

def unit_suffix(unit: str) -> str:
    if unit == "metric":
        unit = "ºC"
    elif unit == "imperial":
        unit = "ºF"
    else:
        unit = " K"

    return unit


def main() -> None:
    args = get_args()

    city = (
        format_city(args.city) if args.city else get_city()
    )
    api_key = (
        args.api_key[0]
        if args.api_key
        else os.environ.get("OPENWEATHER_API_KEY", OPENWEATHER_API_KEY)
    )
    lang = args.lang[0] if args.lang else "en"
    unit = args.unit[0] if args.unit else "standard"

    weather = get_weather(city, lang, unit, api_key)
    if weather:
        temp, desc = weather.values()
        if args.verbose:
            print(f"{temp}, {desc}")
        else:
            print(f"{temp}")


if __name__ == "__main__":
    main()
