class TrainingSuggestion < ApplicationRecord
  belongs_to :user

  validates :running_distance, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, presence: true
  validates :freq, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 100 }, presence: true
  enum intensity: { E: 0, M: 1, T: 2, I: 3, R: 4 }

  # 練習強度(intensity)ごとにランニング時のVO2maxに対する負荷の比率を定義
  def percent
    case self.intensity
    when 'E'  
      0.66
    when 'M'  
      0.815
    when 'T'  
      0.875
    when 'I'  
      0.975
    when 'R' 
      1.07
    end
  end

  # 1kmあたりのペース導出
  def pace
    time = 1000 / velocity              # 1kmあたりランニング時間(minを小数で)
    min = time.floor.to_i               # 1kmあたりランニング時間(minだけ)
    sec = ((time - min) * 60).to_i      # 1kmあたりランニング時間(secondだけ)
    format("%02d:%02d / km", min, sec)
  end

  # 総ランニング時間の導出
  def pace_time
    time = (1000 / velocity) * self.running_distance  # 総ランニング時間(minを小数で)
    hour = (time / 60).floor.to_i                     # 総ランニング時間(hourだけ)
    min = (time - hour * 60).floor.to_i               # 総ランニング時間(minだけ)
    sec = ((time - hour * 60 - min) * 60).to_i        # 総ランニング時間(secondだけ)
    format("%01d:%02d:%02d", hour, min, sec)
  end

  # 消費カロリーの導出
  def calorie
    time = (1000 / velocity) * self.running_distance                                            # 総ランニング時間(minを小数で)
    mets = self.user.vdot * (percent + self.adjust_intensity.to_f / 100) / 3.5                  # mets導出
    cal = (self.user.weight.present? ? mets * self.user.weight * time * freq / 60 * 1.05 : nil).to_i   # 消費カロリー導出
    "#{cal} kcal"
  end

  # ランニングの速度(m/min)の導出用メソッド
  def velocity
    vdot = self.user.vdot * (percent + self.adjust_intensity.to_f / 100)
    29.54 + 5.000663 * vdot - 0.007546 * vdot ** 2
  end

end
