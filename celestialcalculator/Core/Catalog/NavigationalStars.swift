import Foundation

struct NavigationalStarEntry: Sendable {
    let name: String
    let bayer: String
    let magnitude: Double
    /// Right Ascension at J2000 in degrees
    let raJ2000Deg: Double
    /// Declination at J2000 in degrees
    let decJ2000Deg: Double
    /// Proper motion in RA, μα·cos(δ), arcseconds per year
    let pmRAArcsecPerYear: Double
    /// Proper motion in Dec, arcseconds per year
    let pmDecArcsecPerYear: Double
}

/// The 57 navigational stars used in the Nautical Almanac, plus Polaris (index 57).
/// Coordinates J2000.0. Proper motions from Hipparcos where significant; zero otherwise.
enum NavigationalStars {
    nonisolated static let all: [NavigationalStarEntry] = [
        .init(name: "Acamar",      bayer: "θ Eri",  magnitude: 2.88, raJ2000Deg: 44.5653, decJ2000Deg: -40.3047, pmRAArcsecPerYear: -0.044, pmDecArcsecPerYear: 0.020),
        .init(name: "Achernar",    bayer: "α Eri",  magnitude: 0.45, raJ2000Deg: 24.4285, decJ2000Deg: -57.2367, pmRAArcsecPerYear: 0.088,  pmDecArcsecPerYear: -0.040),
        .init(name: "Acrux",       bayer: "α Cru",  magnitude: 0.77, raJ2000Deg: 186.6496, decJ2000Deg: -63.0991, pmRAArcsecPerYear: -0.035, pmDecArcsecPerYear: -0.014),
        .init(name: "Adhara",      bayer: "ε CMa",  magnitude: 1.50, raJ2000Deg: 104.6565, decJ2000Deg: -28.9721, pmRAArcsecPerYear: 0.003,  pmDecArcsecPerYear: 0.001),
        .init(name: "Aldebaran",   bayer: "α Tau",  magnitude: 0.87, raJ2000Deg: 68.9802,  decJ2000Deg: 16.5093,  pmRAArcsecPerYear: 0.063,  pmDecArcsecPerYear: -0.190),
        .init(name: "Alioth",      bayer: "ε UMa",  magnitude: 1.76, raJ2000Deg: 193.5073, decJ2000Deg: 55.9598,  pmRAArcsecPerYear: 0.111,  pmDecArcsecPerYear: -0.009),
        .init(name: "Alkaid",      bayer: "η UMa",  magnitude: 1.85, raJ2000Deg: 206.8852, decJ2000Deg: 49.3133,  pmRAArcsecPerYear: -0.121, pmDecArcsecPerYear: -0.015),
        .init(name: "Al Na'ir",    bayer: "α Gru",  magnitude: 1.73, raJ2000Deg: 332.0583, decJ2000Deg: -46.9610, pmRAArcsecPerYear: 0.127,  pmDecArcsecPerYear: -0.148),
        .init(name: "Alnilam",     bayer: "ε Ori",  magnitude: 1.69, raJ2000Deg: 84.0533,  decJ2000Deg: -1.2019,  pmRAArcsecPerYear: 0.001,  pmDecArcsecPerYear: -0.002),
        .init(name: "Alphard",     bayer: "α Hya",  magnitude: 1.99, raJ2000Deg: 141.8968, decJ2000Deg: -8.6586,  pmRAArcsecPerYear: -0.014, pmDecArcsecPerYear: 0.033),
        .init(name: "Alphecca",    bayer: "α CrB",  magnitude: 2.23, raJ2000Deg: 233.6717, decJ2000Deg: 26.7148,  pmRAArcsecPerYear: 0.121,  pmDecArcsecPerYear: -0.090),
        .init(name: "Alpheratz",   bayer: "α And",  magnitude: 2.07, raJ2000Deg: 2.0969,   decJ2000Deg: 29.0904,  pmRAArcsecPerYear: 0.135,  pmDecArcsecPerYear: -0.163),
        .init(name: "Altair",      bayer: "α Aql",  magnitude: 0.76, raJ2000Deg: 297.6957, decJ2000Deg: 8.8683,   pmRAArcsecPerYear: 0.536,  pmDecArcsecPerYear: 0.385),
        .init(name: "Ankaa",       bayer: "α Phe",  magnitude: 2.40, raJ2000Deg: 6.5709,   decJ2000Deg: -42.3060, pmRAArcsecPerYear: 0.232,  pmDecArcsecPerYear: -0.353),
        .init(name: "Antares",     bayer: "α Sco",  magnitude: 1.06, raJ2000Deg: 247.3519, decJ2000Deg: -26.4320, pmRAArcsecPerYear: -0.010, pmDecArcsecPerYear: -0.023),
        .init(name: "Arcturus",    bayer: "α Boo",  magnitude: -0.05, raJ2000Deg: 213.9153, decJ2000Deg: 19.1824, pmRAArcsecPerYear: -1.093, pmDecArcsecPerYear: -1.999),
        .init(name: "Atria",       bayer: "α TrA",  magnitude: 1.91, raJ2000Deg: 252.1660, decJ2000Deg: -69.0277, pmRAArcsecPerYear: 0.018,  pmDecArcsecPerYear: -0.034),
        .init(name: "Avior",       bayer: "ε Car",  magnitude: 1.86, raJ2000Deg: 125.6284, decJ2000Deg: -59.5095, pmRAArcsecPerYear: -0.025, pmDecArcsecPerYear: 0.022),
        .init(name: "Bellatrix",   bayer: "γ Ori",  magnitude: 1.64, raJ2000Deg: 81.2828,  decJ2000Deg: 6.3497,   pmRAArcsecPerYear: -0.009, pmDecArcsecPerYear: -0.013),
        .init(name: "Betelgeuse",  bayer: "α Ori",  magnitude: 0.45, raJ2000Deg: 88.7929,  decJ2000Deg: 7.4071,   pmRAArcsecPerYear: 0.027,  pmDecArcsecPerYear: 0.011),
        .init(name: "Canopus",     bayer: "α Car",  magnitude: -0.62, raJ2000Deg: 95.9879, decJ2000Deg: -52.6957, pmRAArcsecPerYear: 0.020,  pmDecArcsecPerYear: 0.024),
        .init(name: "Capella",     bayer: "α Aur",  magnitude: 0.08, raJ2000Deg: 79.1723,  decJ2000Deg: 45.9980,  pmRAArcsecPerYear: 0.076,  pmDecArcsecPerYear: -0.428),
        .init(name: "Deneb",       bayer: "α Cyg",  magnitude: 1.25, raJ2000Deg: 310.3580, decJ2000Deg: 45.2803,  pmRAArcsecPerYear: 0.002,  pmDecArcsecPerYear: 0.002),
        .init(name: "Denebola",    bayer: "β Leo",  magnitude: 2.14, raJ2000Deg: 177.2649, decJ2000Deg: 14.5720,  pmRAArcsecPerYear: -0.499, pmDecArcsecPerYear: -0.114),
        .init(name: "Diphda",      bayer: "β Cet",  magnitude: 2.04, raJ2000Deg: 10.8975,  decJ2000Deg: -17.9866, pmRAArcsecPerYear: 0.232,  pmDecArcsecPerYear: 0.033),
        .init(name: "Dubhe",       bayer: "α UMa",  magnitude: 1.81, raJ2000Deg: 165.9320, decJ2000Deg: 61.7510,  pmRAArcsecPerYear: -0.137, pmDecArcsecPerYear: -0.035),
        .init(name: "Elnath",      bayer: "β Tau",  magnitude: 1.65, raJ2000Deg: 81.5730,  decJ2000Deg: 28.6075,  pmRAArcsecPerYear: 0.023,  pmDecArcsecPerYear: -0.175),
        .init(name: "Eltanin",     bayer: "γ Dra",  magnitude: 2.24, raJ2000Deg: 269.1515, decJ2000Deg: 51.4889,  pmRAArcsecPerYear: -0.008, pmDecArcsecPerYear: -0.023),
        .init(name: "Enif",        bayer: "ε Peg",  magnitude: 2.39, raJ2000Deg: 326.0464, decJ2000Deg: 9.8750,   pmRAArcsecPerYear: 0.026,  pmDecArcsecPerYear: 0.000),
        .init(name: "Fomalhaut",   bayer: "α PsA",  magnitude: 1.17, raJ2000Deg: 344.4127, decJ2000Deg: -29.6222, pmRAArcsecPerYear: 0.330,  pmDecArcsecPerYear: -0.164),
        .init(name: "Gacrux",      bayer: "γ Cru",  magnitude: 1.59, raJ2000Deg: 187.7915, decJ2000Deg: -57.1133, pmRAArcsecPerYear: 0.028,  pmDecArcsecPerYear: -0.265),
        .init(name: "Gienah",      bayer: "γ Crv",  magnitude: 2.59, raJ2000Deg: 183.9514, decJ2000Deg: -17.5419, pmRAArcsecPerYear: -0.158, pmDecArcsecPerYear: 0.022),
        .init(name: "Hadar",       bayer: "β Cen",  magnitude: 0.61, raJ2000Deg: 210.9559, decJ2000Deg: -60.3730, pmRAArcsecPerYear: -0.033, pmDecArcsecPerYear: -0.025),
        .init(name: "Hamal",       bayer: "α Ari",  magnitude: 2.00, raJ2000Deg: 31.7933,  decJ2000Deg: 23.4624,  pmRAArcsecPerYear: 0.190,  pmDecArcsecPerYear: -0.146),
        .init(name: "Kaus Australis", bayer: "ε Sgr", magnitude: 1.85, raJ2000Deg: 276.0430, decJ2000Deg: -34.3847, pmRAArcsecPerYear: -0.039, pmDecArcsecPerYear: -0.124),
        .init(name: "Kochab",      bayer: "β UMi",  magnitude: 2.07, raJ2000Deg: 222.6764, decJ2000Deg: 74.1555,  pmRAArcsecPerYear: -0.033, pmDecArcsecPerYear: 0.012),
        .init(name: "Markab",      bayer: "α Peg",  magnitude: 2.49, raJ2000Deg: 346.1903, decJ2000Deg: 15.2053,  pmRAArcsecPerYear: 0.061,  pmDecArcsecPerYear: -0.043),
        .init(name: "Menkar",      bayer: "α Cet",  magnitude: 2.54, raJ2000Deg: 45.5699,  decJ2000Deg: 4.0897,   pmRAArcsecPerYear: -0.011, pmDecArcsecPerYear: -0.078),
        .init(name: "Menkent",     bayer: "θ Cen",  magnitude: 2.06, raJ2000Deg: 211.6708, decJ2000Deg: -36.3700, pmRAArcsecPerYear: -0.520, pmDecArcsecPerYear: -0.518),
        .init(name: "Miaplacidus", bayer: "β Car",  magnitude: 1.67, raJ2000Deg: 138.3000, decJ2000Deg: -69.7172, pmRAArcsecPerYear: -0.158, pmDecArcsecPerYear: 0.108),
        .init(name: "Mirfak",      bayer: "α Per",  magnitude: 1.79, raJ2000Deg: 51.0807,  decJ2000Deg: 49.8612,  pmRAArcsecPerYear: 0.024,  pmDecArcsecPerYear: -0.026),
        .init(name: "Nunki",       bayer: "σ Sgr",  magnitude: 2.02, raJ2000Deg: 283.8164, decJ2000Deg: -26.2967, pmRAArcsecPerYear: 0.013,  pmDecArcsecPerYear: -0.052),
        .init(name: "Peacock",     bayer: "α Pav",  magnitude: 1.94, raJ2000Deg: 306.4120, decJ2000Deg: -56.7350, pmRAArcsecPerYear: 0.007,  pmDecArcsecPerYear: -0.087),
        .init(name: "Pollux",      bayer: "β Gem",  magnitude: 1.16, raJ2000Deg: 116.3289, decJ2000Deg: 28.0262,  pmRAArcsecPerYear: -0.626, pmDecArcsecPerYear: -0.046),
        .init(name: "Procyon",     bayer: "α CMi",  magnitude: 0.40, raJ2000Deg: 114.8255, decJ2000Deg: 5.2250,   pmRAArcsecPerYear: -0.716, pmDecArcsecPerYear: -1.034),
        .init(name: "Rasalhague",  bayer: "α Oph",  magnitude: 2.08, raJ2000Deg: 263.7335, decJ2000Deg: 12.5601,  pmRAArcsecPerYear: 0.110,  pmDecArcsecPerYear: -0.222),
        .init(name: "Regulus",     bayer: "α Leo",  magnitude: 1.36, raJ2000Deg: 152.0930, decJ2000Deg: 11.9672,  pmRAArcsecPerYear: -0.249, pmDecArcsecPerYear: 0.005),
        .init(name: "Rigel",       bayer: "β Ori",  magnitude: 0.18, raJ2000Deg: 78.6345,  decJ2000Deg: -8.2017,  pmRAArcsecPerYear: 0.002,  pmDecArcsecPerYear: -0.001),
        .init(name: "Rigil Kent",  bayer: "α Cen",  magnitude: -0.01, raJ2000Deg: 219.9202, decJ2000Deg: -60.8340, pmRAArcsecPerYear: -3.679, pmDecArcsecPerYear: 0.474),
        .init(name: "Sabik",       bayer: "η Oph",  magnitude: 2.43, raJ2000Deg: 257.5946, decJ2000Deg: -15.7249, pmRAArcsecPerYear: 0.041,  pmDecArcsecPerYear: 0.099),
        .init(name: "Schedar",     bayer: "α Cas",  magnitude: 2.24, raJ2000Deg: 10.1268,  decJ2000Deg: 56.5374,  pmRAArcsecPerYear: 0.051,  pmDecArcsecPerYear: -0.032),
        .init(name: "Shaula",      bayer: "λ Sco",  magnitude: 1.62, raJ2000Deg: 263.4022, decJ2000Deg: -37.1038, pmRAArcsecPerYear: -0.009, pmDecArcsecPerYear: -0.030),
        .init(name: "Sirius",      bayer: "α CMa",  magnitude: -1.46, raJ2000Deg: 101.2872, decJ2000Deg: -16.7161, pmRAArcsecPerYear: -0.546, pmDecArcsecPerYear: -1.223),
        .init(name: "Spica",       bayer: "α Vir",  magnitude: 0.98, raJ2000Deg: 201.2983, decJ2000Deg: -11.1614, pmRAArcsecPerYear: -0.042, pmDecArcsecPerYear: -0.030),
        .init(name: "Suhail",      bayer: "λ Vel",  magnitude: 2.21, raJ2000Deg: 136.9990, decJ2000Deg: -43.4326, pmRAArcsecPerYear: -0.024, pmDecArcsecPerYear: 0.014),
        .init(name: "Vega",        bayer: "α Lyr",  magnitude: 0.03, raJ2000Deg: 279.2347, decJ2000Deg: 38.7837,  pmRAArcsecPerYear: 0.201,  pmDecArcsecPerYear: 0.287),
        .init(name: "Zubenelgenubi", bayer: "α Lib", magnitude: 2.75, raJ2000Deg: 222.7196, decJ2000Deg: -16.0418, pmRAArcsecPerYear: -0.105, pmDecArcsecPerYear: -0.069),
        .init(name: "Polaris",     bayer: "α UMi",  magnitude: 2.02, raJ2000Deg: 37.9546,  decJ2000Deg: 89.2641,  pmRAArcsecPerYear: 0.044,  pmDecArcsecPerYear: -0.012)
    ]

    static let count: Int = all.count
}
