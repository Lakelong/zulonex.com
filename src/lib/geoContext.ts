export interface GeoCity {
  cityName: string;
  slug?: string;
}

export interface GeoContext {
  currentCity: GeoCity;
}

export const defaultGeoContext: GeoContext = {
  currentCity: {
    cityName: "全国",
    slug: "national"
  }
};

function normalizeCityName(value: string | null | undefined) {
  const cityName = String(value ?? "").trim().slice(0, 32);
  if (!cityName || ["all", "national", "全国"].includes(cityName.toLowerCase())) {
    return defaultGeoContext.currentCity.cityName;
  }

  return cityName;
}

/** Resolve the current GEO city from ?city=城市, with 全国 as the fallback. */
export function getGeoContext(url: URL): GeoContext {
  const cityName = normalizeCityName(url.searchParams.get("city") || import.meta.env.PUBLIC_GEO_CITY);

  return {
    currentCity: {
      cityName,
      slug: cityName === "全国" ? "national" : encodeURIComponent(cityName)
    }
  };
}

export function getGeoSeoTitle(geoContext: GeoContext) {
  return `${geoContext.currentCity.cityName}星鹿爱学/逐鹿未来官网 - 本地智能教育服务`;
}
