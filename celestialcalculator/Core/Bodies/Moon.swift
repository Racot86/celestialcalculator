import Foundation

/// Moon position via Meeus chapter 47 — geocentric apparent (truncated to leading terms).
/// Accuracy ~0.05° in longitude — adequate for navigational azimuth at typical use.
struct Moon: CelestialBody {
    func apparentEquatorial(jdUT: Double) -> EquatorialCoordinates {
        let jde = JulianDate.jde(from: jdUT)
        let t = JulianDate.centuriesSinceJ2000(jd: jde)
        let d2r = Double.pi / 180.0

        let Lp = AngleMath.normalizeDegrees(218.3164477 + 481267.88123421 * t
                                            - 0.0015786 * t*t + t*t*t/538841.0 - t*t*t*t/65194000.0)
        let D  = AngleMath.normalizeDegrees(297.8501921 + 445267.1114034 * t
                                            - 0.0018819 * t*t + t*t*t/545868.0 - t*t*t*t/113065000.0)
        let M  = AngleMath.normalizeDegrees(357.5291092 + 35999.0502909 * t
                                            - 0.0001536 * t*t + t*t*t/24490000.0)
        let Mp = AngleMath.normalizeDegrees(134.9633964 + 477198.8675055 * t
                                            + 0.0087414 * t*t + t*t*t/69699.0 - t*t*t*t/14712000.0)
        let F  = AngleMath.normalizeDegrees(93.2720950 + 483202.0175233 * t
                                            - 0.0036539 * t*t - t*t*t/3526000.0 + t*t*t*t/863310000.0)
        let E  = 1 - 0.002516 * t - 0.0000074 * t*t

        let Dr = D * d2r, Mr = M * d2r, Mpr = Mp * d2r, Fr = F * d2r

        // (D, M, M', F, sin coefficient [millionths of degree], cos coefficient for distance [km])
        // Selected leading longitude/distance terms
        struct LRTerm { let d: Double; let m: Double; let mp: Double; let f: Double; let l: Double; let r: Double }
        let lrTerms: [LRTerm] = [
            .init(d:0,m:0,mp:1,f:0,l:6288774, r:-20905355),
            .init(d:2,m:0,mp:-1,f:0,l:1274027, r:-3699111),
            .init(d:2,m:0,mp:0,f:0,l:658314,   r:-2955968),
            .init(d:0,m:0,mp:2,f:0,l:213618,   r:-569925),
            .init(d:0,m:1,mp:0,f:0,l:-185116,  r:48888),
            .init(d:0,m:0,mp:0,f:2,l:-114332,  r:-3149),
            .init(d:2,m:0,mp:-2,f:0,l:58793,   r:246158),
            .init(d:2,m:-1,mp:-1,f:0,l:57066,  r:-152138),
            .init(d:2,m:0,mp:1,f:0,l:53322,    r:-170733),
            .init(d:2,m:-1,mp:0,f:0,l:45758,   r:-204586),
            .init(d:0,m:1,mp:-1,f:0,l:-40923,  r:-129620),
            .init(d:1,m:0,mp:0,f:0,l:-34720,   r:108743),
            .init(d:0,m:1,mp:1,f:0,l:-30383,   r:104755),
            .init(d:2,m:0,mp:0,f:-2,l:15327,   r:10321),
            .init(d:0,m:0,mp:1,f:2,l:-12528,   r:0),
            .init(d:0,m:0,mp:1,f:-2,l:10980,   r:79661),
            .init(d:4,m:0,mp:-1,f:0,l:10675,   r:-34782),
            .init(d:0,m:0,mp:3,f:0,l:10034,    r:-23210),
            .init(d:4,m:0,mp:-2,f:0,l:8548,    r:-21636),
            .init(d:2,m:1,mp:-1,f:0,l:-7888,   r:24208),
            .init(d:2,m:1,mp:0,f:0,l:-6766,    r:30824),
            .init(d:1,m:0,mp:-1,f:0,l:-5163,   r:-8379),
            .init(d:1,m:1,mp:0,f:0,l:4987,     r:-16675),
            .init(d:2,m:-1,mp:1,f:0,l:4036,    r:-12831),
            .init(d:2,m:0,mp:2,f:0,l:3994,     r:-10445),
            .init(d:4,m:0,mp:0,f:0,l:3861,     r:-11650),
            .init(d:2,m:0,mp:-3,f:0,l:3665,    r:14403),
            .init(d:0,m:1,mp:-2,f:0,l:-2689,   r:-7003),
            .init(d:2,m:0,mp:-1,f:2,l:-2602,   r:0),
            .init(d:2,m:-1,mp:-2,f:0,l:2390,   r:10056),
            .init(d:1,m:0,mp:1,f:0,l:-2348,    r:6322),
            .init(d:2,m:-2,mp:0,f:0,l:2236,    r:-9884),
            .init(d:0,m:1,mp:2,f:0,l:-2120,    r:5751),
            .init(d:0,m:2,mp:0,f:0,l:-2069,    r:0),
            .init(d:2,m:-2,mp:-1,f:0,l:2048,   r:-4950),
            .init(d:2,m:0,mp:1,f:-2,l:-1773,   r:4130),
            .init(d:2,m:0,mp:0,f:2,l:-1595,    r:0),
            .init(d:4,m:-1,mp:-1,f:0,l:1215,   r:-3958),
            .init(d:0,m:0,mp:2,f:2,l:-1110,    r:0),
            .init(d:3,m:0,mp:-1,f:0,l:-892,    r:3258),
            .init(d:2,m:1,mp:1,f:0,l:-810,     r:2616),
            .init(d:4,m:-1,mp:-2,f:0,l:759,    r:-1897),
            .init(d:0,m:2,mp:-1,f:0,l:-713,    r:-2117),
            .init(d:2,m:2,mp:-1,f:0,l:-700,    r:2354),
            .init(d:2,m:1,mp:-2,f:0,l:691,     r:0),
            .init(d:2,m:-1,mp:0,f:-2,l:596,    r:0),
            .init(d:4,m:0,mp:1,f:0,l:549,      r:-1423),
            .init(d:0,m:0,mp:4,f:0,l:537,      r:-1117),
            .init(d:4,m:-1,mp:0,f:0,l:520,     r:-1571),
            .init(d:1,m:0,mp:-2,f:0,l:-487,    r:-1739),
            .init(d:2,m:1,mp:0,f:-2,l:-399,    r:0),
            .init(d:0,m:0,mp:2,f:-2,l:-381,    r:-4421),
            .init(d:1,m:1,mp:1,f:0,l:351,      r:0),
            .init(d:3,m:0,mp:-2,f:0,l:-340,    r:0),
            .init(d:4,m:0,mp:-3,f:0,l:330,     r:0),
            .init(d:2,m:-1,mp:2,f:0,l:327,     r:0),
            .init(d:0,m:2,mp:1,f:0,l:-323,     r:1165),
            .init(d:1,m:1,mp:-1,f:0,l:299,     r:0),
            .init(d:2,m:0,mp:3,f:0,l:294,      r:0),
            .init(d:2,m:0,mp:-1,f:-2,l:0,      r:8752)
        ]

        struct BTerm { let d: Double; let m: Double; let mp: Double; let f: Double; let b: Double }
        let bTerms: [BTerm] = [
            .init(d:0,m:0,mp:0,f:1,b:5128122),
            .init(d:0,m:0,mp:1,f:1,b:280602),
            .init(d:0,m:0,mp:1,f:-1,b:277693),
            .init(d:2,m:0,mp:0,f:-1,b:173237),
            .init(d:2,m:0,mp:-1,f:1,b:55413),
            .init(d:2,m:0,mp:-1,f:-1,b:46271),
            .init(d:2,m:0,mp:0,f:1,b:32573),
            .init(d:0,m:0,mp:2,f:1,b:17198),
            .init(d:2,m:0,mp:1,f:-1,b:9266),
            .init(d:0,m:0,mp:2,f:-1,b:8822),
            .init(d:2,m:-1,mp:0,f:-1,b:8216),
            .init(d:2,m:0,mp:-2,f:-1,b:4324),
            .init(d:2,m:0,mp:1,f:1,b:4200),
            .init(d:2,m:1,mp:0,f:-1,b:-3359),
            .init(d:2,m:-1,mp:-1,f:1,b:2463),
            .init(d:2,m:-1,mp:0,f:1,b:2211),
            .init(d:2,m:-1,mp:-1,f:-1,b:2065),
            .init(d:0,m:1,mp:-1,f:-1,b:-1870),
            .init(d:4,m:0,mp:-1,f:-1,b:1828),
            .init(d:0,m:1,mp:0,f:1,b:-1794),
            .init(d:0,m:0,mp:0,f:3,b:-1749),
            .init(d:0,m:1,mp:-1,f:1,b:-1565),
            .init(d:1,m:0,mp:0,f:1,b:-1491),
            .init(d:0,m:1,mp:1,f:1,b:-1475),
            .init(d:0,m:1,mp:1,f:-1,b:-1410),
            .init(d:0,m:1,mp:0,f:-1,b:-1344),
            .init(d:1,m:0,mp:0,f:-1,b:-1335),
            .init(d:0,m:0,mp:3,f:1,b:1107),
            .init(d:4,m:0,mp:0,f:-1,b:1021),
            .init(d:4,m:0,mp:-1,f:1,b:833),
            .init(d:0,m:0,mp:1,f:-3,b:777),
            .init(d:4,m:0,mp:-2,f:1,b:671),
            .init(d:2,m:0,mp:0,f:-3,b:607),
            .init(d:2,m:0,mp:2,f:-1,b:596),
            .init(d:2,m:-1,mp:1,f:-1,b:491),
            .init(d:2,m:0,mp:-2,f:1,b:-451),
            .init(d:0,m:0,mp:3,f:-1,b:439),
            .init(d:2,m:0,mp:2,f:1,b:422),
            .init(d:2,m:0,mp:-3,f:-1,b:421)
        ]

        var sumL = 0.0, sumR = 0.0, sumB = 0.0
        for t in lrTerms {
            let arg = t.d*Dr + t.m*Mr + t.mp*Mpr + t.f*Fr
            var ee = 1.0
            if abs(t.m) == 1 { ee = E } else if abs(t.m) == 2 { ee = E*E }
            sumL += ee * t.l * sin(arg)
            sumR += ee * t.r * cos(arg)
        }
        for t in bTerms {
            let arg = t.d*Dr + t.m*Mr + t.mp*Mpr + t.f*Fr
            var ee = 1.0
            if abs(t.m) == 1 { ee = E } else if abs(t.m) == 2 { ee = E*E }
            sumB += ee * t.b * sin(arg)
        }

        // Additive terms (planetary perturbations) — small; skip for nav accuracy.
        let lambdaDeg = Lp + sumL / 1_000_000.0
        let betaDeg = sumB / 1_000_000.0
        let distanceKm = 385000.56 + sumR / 1000.0
        _ = distanceKm

        // Apparent longitude: add nutation in longitude
        let dpsi = Nutation.nutationInLongitude(jde: jde)
        let lambda = AngleMath.degToRad(lambdaDeg) + dpsi
        let beta = AngleMath.degToRad(betaDeg)
        let eps = Obliquity.trueObliquity(jde: jde)
        return EclipticToEquatorial.convert(longitudeRad: lambda, latitudeRad: beta, obliquityRad: eps)
    }
}
