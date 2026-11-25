export type PhoneScreen =
  | 'dashboard'
  | 'risk'
  | 'lab'
  | 'insights'
  | 'report'

export type GlassCardVariant = 'metric' | 'alert' | 'question' | 'scan'

export type RiskLevel = 'low' | 'medium' | 'high'

export interface MetricData {
  label: string
  value: string
  unit?: string
  status?: 'normal' | 'warning' | 'critical'
  icon?: string
}

export interface AlertData {
  title: string
  description: string
  level: RiskLevel
}

export interface FeatureItem {
  id: string
  overline: string
  headline: string
  body: string
  screen: PhoneScreen
}
