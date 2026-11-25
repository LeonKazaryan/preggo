//
//  PregnancyWeekData.swift
//  Preggo
//
//  Static reference data for each week of pregnancy (1–42).
//  Used in the Home tab and onboarding week selector.
//

import Foundation

struct WeekInfo {
    let week: Int
    let babySize: String
    let babyLength: String
    let milestone: String
    let tip: String
}

enum PregnancyWeekData {

    static func info(for week: Int) -> WeekInfo {
        let clamped = min(max(week, 1), 42)
        return weeks[clamped - 1]
    }

    static let weeks: [WeekInfo] = [
        WeekInfo(week: 1,  babySize: "Poppy seed",       babyLength: "<1 mm",    milestone: "Fertilization occurs",                        tip: "Start taking prenatal vitamins with folic acid"),
        WeekInfo(week: 2,  babySize: "Poppy seed",       babyLength: "<1 mm",    milestone: "Implantation begins",                         tip: "Avoid alcohol and smoking"),
        WeekInfo(week: 3,  babySize: "Poppy seed",       babyLength: "0.1 mm",   milestone: "Embryo is forming",                           tip: "Stay hydrated and rest well"),
        WeekInfo(week: 4,  babySize: "Poppy seed",       babyLength: "1 mm",     milestone: "Neural tube begins to form",                  tip: "Schedule your first prenatal appointment"),
        WeekInfo(week: 5,  babySize: "Sesame seed",      babyLength: "2 mm",     milestone: "Heart begins to beat",                        tip: "Morning sickness may start — eat small meals"),
        WeekInfo(week: 6,  babySize: "Lentil",           babyLength: "5 mm",     milestone: "Facial features forming",                     tip: "Get plenty of rest and stay active"),
        WeekInfo(week: 7,  babySize: "Blueberry",        babyLength: "1.2 cm",   milestone: "Arms and legs developing",                    tip: "Consider gentle prenatal yoga"),
        WeekInfo(week: 8,  babySize: "Raspberry",        babyLength: "1.6 cm",   milestone: "Fingers and toes forming",                    tip: "First ultrasound may be scheduled"),
        WeekInfo(week: 9,  babySize: "Cherry",           babyLength: "2.3 cm",   milestone: "Essential organs have formed",                tip: "Continue taking folic acid daily"),
        WeekInfo(week: 10, babySize: "Strawberry",       babyLength: "3.1 cm",   milestone: "Baby can now move",                           tip: "Stay well-hydrated — aim for 8+ glasses"),
        WeekInfo(week: 11, babySize: "Lime",             babyLength: "4.1 cm",   milestone: "Bones beginning to harden",                   tip: "NIPT screening may be offered"),
        WeekInfo(week: 12, babySize: "Plum",             babyLength: "5.4 cm",   milestone: "Reflexes developing",                         tip: "End of first trimester — risk of miscarriage drops"),
        WeekInfo(week: 13, babySize: "Lemon",            babyLength: "7.4 cm",   milestone: "Vocal cords forming",                         tip: "You may start feeling more energetic"),
        WeekInfo(week: 14, babySize: "Nectarine",        babyLength: "8.7 cm",   milestone: "Baby can squint and frown",                   tip: "Good time to start gentle exercise routine"),
        WeekInfo(week: 15, babySize: "Apple",            babyLength: "10.1 cm",  milestone: "Skeleton becoming visible on scans",           tip: "Consider a maternity wardrobe soon"),
        WeekInfo(week: 16, babySize: "Avocado",          babyLength: "11.6 cm",  milestone: "Baby can hear sounds",                        tip: "Quad screen blood test may be offered"),
        WeekInfo(week: 17, babySize: "Pear",             babyLength: "13 cm",    milestone: "Fat stores beginning to develop",              tip: "Sleep on your side for better circulation"),
        WeekInfo(week: 18, babySize: "Bell pepper",      babyLength: "14.2 cm",  milestone: "Baby is yawning and hiccupping",               tip: "Anatomy scan (20-week ultrasound) coming up"),
        WeekInfo(week: 19, babySize: "Mango",            babyLength: "15.3 cm",  milestone: "Sensory development accelerating",             tip: "You may start feeling baby's first kicks"),
        WeekInfo(week: 20, babySize: "Banana",           babyLength: "25.6 cm",  milestone: "Halfway there! Anatomy scan time",             tip: "Celebrate the halfway mark"),
        WeekInfo(week: 21, babySize: "Carrot",           babyLength: "26.7 cm",  milestone: "Baby's movements getting stronger",            tip: "Start tracking kick counts if recommended"),
        WeekInfo(week: 22, babySize: "Papaya",           babyLength: "27.8 cm",  milestone: "Eyes and lips are more developed",             tip: "Consider childbirth classes"),
        WeekInfo(week: 23, babySize: "Grapefruit",       babyLength: "28.9 cm",  milestone: "Baby can hear your voice",                    tip: "Talk and sing to your baby"),
        WeekInfo(week: 24, babySize: "Corn on the cob",  babyLength: "30 cm",    milestone: "Lungs developing surfactant",                  tip: "Glucose tolerance test (GCT) coming up"),
        WeekInfo(week: 25, babySize: "Cauliflower",      babyLength: "34.6 cm",  milestone: "Baby responds to your voice",                  tip: "Watch for signs of gestational diabetes"),
        WeekInfo(week: 26, babySize: "Lettuce head",     babyLength: "35.6 cm",  milestone: "Eyes opening for the first time",              tip: "Start planning your birth plan"),
        WeekInfo(week: 27, babySize: "Rutabaga",         babyLength: "36.6 cm",  milestone: "Brain is very active now",                     tip: "Third trimester begins — rest often"),
        WeekInfo(week: 28, babySize: "Eggplant",         babyLength: "37.6 cm",  milestone: "Baby can blink and dream",                     tip: "Rh factor blood test may be done"),
        WeekInfo(week: 29, babySize: "Butternut squash", babyLength: "38.6 cm",  milestone: "Bones are fully developed",                    tip: "Monitor for swelling in hands and feet"),
        WeekInfo(week: 30, babySize: "Cabbage",          babyLength: "39.9 cm",  milestone: "Baby is gaining weight rapidly",               tip: "Practice breathing exercises"),
        WeekInfo(week: 31, babySize: "Coconut",          babyLength: "41.1 cm",  milestone: "All five senses are working",                  tip: "Finalize your hospital bag"),
        WeekInfo(week: 32, babySize: "Jicama",           babyLength: "42.4 cm",  milestone: "Baby is practicing breathing",                 tip: "Prenatal visits increase to biweekly"),
        WeekInfo(week: 33, babySize: "Pineapple",        babyLength: "43.7 cm",  milestone: "Immune system developing",                     tip: "Rest as much as possible"),
        WeekInfo(week: 34, babySize: "Cantaloupe",       babyLength: "45 cm",    milestone: "Central nervous system maturing",               tip: "Group B strep test coming soon"),
        WeekInfo(week: 35, babySize: "Honeydew melon",   babyLength: "46.2 cm",  milestone: "Kidneys fully developed",                      tip: "Review your birth plan with your doctor"),
        WeekInfo(week: 36, babySize: "Romaine lettuce",  babyLength: "47.4 cm",  milestone: "Baby is dropping into pelvis",                  tip: "Weekly prenatal visits begin"),
        WeekInfo(week: 37, babySize: "Swiss chard",      babyLength: "48.6 cm",  milestone: "Considered early term",                        tip: "Know the signs of labor"),
        WeekInfo(week: 38, babySize: "Leek",             babyLength: "49.8 cm",  milestone: "Organs are fully mature",                      tip: "Pack your hospital bag if you haven't"),
        WeekInfo(week: 39, babySize: "Watermelon",       babyLength: "50.7 cm",  milestone: "Full term — baby is ready",                    tip: "Rest, relax, and stay close to your hospital"),
        WeekInfo(week: 40, babySize: "Pumpkin",          babyLength: "51.2 cm",  milestone: "Due date! Baby is fully developed",             tip: "Trust your body — labor may start any time"),
        WeekInfo(week: 41, babySize: "Pumpkin",          babyLength: "51.5 cm",  milestone: "Post-term — doctor may discuss induction",      tip: "Stay in close contact with your healthcare provider"),
        WeekInfo(week: 42, babySize: "Pumpkin",          babyLength: "51.7 cm",  milestone: "Induction likely recommended",                  tip: "Follow your doctor's guidance closely"),
    ]
}
