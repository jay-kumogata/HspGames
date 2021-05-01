-- 2019-05-29
-- Asteroids Game ���

-- ���LURL�̎�������͂����B
-- https://github.com/nikoheikkila/asteroids

-- Gloss���C�u�����x�[�X�Ő݌v����Ă���B
module Main where
import Graphics.Gloss
import Graphics.Gloss.Interface.Pure.Game
import Graphics.Gloss.Interface.Pure.Simulate
import Graphics.Gloss.Interface.Pure.Display

-- AsteroidWorld�Ƃ����Q�[�����E�̒�`�B
-- data AsteroidWorld = Play [Rock] Ship UFO [Bullet] 
data AsteroidWorld = Play [Rock] Ship [Bullet] Score
                   | GameOver
                   deriving (Eq,Show)

-- Play�́AGloss���C�u�����̍\�z�q�B
-- [Rock]�͊���̃��X�g�B
-- Ship�͑D���B
-- [Bullet]�͒e���̃��X�g�B

type Velocity     = (Float, Float)  -- ���xVelocity�́A�P���xFloat�̃y�A�B
type Size         = Float           -- Size is Float
type Age          = Float           -- Age is Float
type Score       = Integer        -- Score is Integer

-- �D���Ship�́A���WPointInSpace�A���xVelocity����\���B
data Ship   = Ship   PointInSpace Velocity
    deriving (Eq,Show)
-- �e���Bullet�́A���WPointInSpace�A���xVelocity�A�N��Age����\���B
data Bullet = Bullet PointInSpace Velocity Age
    deriving (Eq,Show)
-- ����Rock�́A���WPointInSpace�A�T�C�YSize�A���xVelocity����\���B
data Rock   = Rock   PointInSpace Size Velocity
    deriving (Eq,Show)
-- Our UFO --
-- data UFO    = UFO  PointInSpace Velocity
--    deriving (Eq, Show)

-- ���������ꂽ�Q�[�����E��ԋp����֐�initialWorld���`�B
initialWorld :: AsteroidWorld
initialWorld = Play
                   [Rock (150,150)  45 (2,6)
                   ,Rock (-45,201)  45 (13,-8)
                   ,Rock (45,22)    25 (-2,8)
                   ,Rock (-210,-15) 30 (-2,-8)
                   ,Rock (-45,-201) 25 (8,2)
                   ] -- The default rocks
                   (Ship (0,0) (0,0)) -- The initial ship
--                   (UFO  (75, 75) (2, 5)) -- The initial UFO
                   [] -- The initial bullets (none)
                   0

-- �Q�[�����E���V�~�����[�g����֐�simulateWorld���`�B
-- ��1����Float�́A�o�ߎ���timeStep���w��B
-- ��2����AsteroidWorld�́A�����_�ł̃Q�[�����E���w��B
-- ��3����AsteroidWorld�́A���Ԍo�߂�����̃Q�[�����E���ԋp�B

simulateWorld :: Float -> (AsteroidWorld -> AsteroidWorld)

-- �Q�[���I�[�o�[�̏ꍇ�́A�Q�[���I�[�o��ԋp�B
simulateWorld _        GameOver          = GameOver

-- simulateWorld timeStep (Play rocks (Ship shipPos shipV) (UFO ufoPos ufoV) bullets)
simulateWorld timeStep (Play rocks (Ship shipPos shipV) bullets score)
  | any (collidesWith shipPos) rocks = GameOver
  -- | (collidesWithUFO shipPos) UFO = GameOver
  | otherwise = Play (concatMap updateRock rocks)
                              (Ship newShipPos shipV)
--                              (UFO newUFOPos ufoV)
                              (concat (map updateBullet bullets))
                              score
  where
    -- ���Wp���A��Rock�ɏՓ˂������ۂ���ԋp�B
    -- ����Wrp�����T�C�Ys�������ꂽ�̈�i�~�j�ɁA���Wp���܂܂�邩�ۂ���ԋp�B
      collidesWith :: PointInSpace -> Rock -> Bool
      collidesWith p (Rock rp s _)
       = magV (rp .- p) < s

    -- �����ꂩ�̒e���Wbp���A��r�ɏՓ˂������ۂ���ԋp�B
      collidesWithBullet :: Rock -> Bool
      collidesWithBullet r
       = any (\(Bullet bp _ _) -> collidesWith bp r) bullets

    -- ���Wp���A�GUFO�ɏՓ˂������ۂ���ԋp�B
    -- �G���Wup����10�������ꂽ�̈�i�~�j�ɁA���Wp���܂܂�邩�ۂ���ԋp�B

   -- collidesWithUFO :: PointInSpace -> UFO -> Bool
   -- collidesWithUFO p (UFO up _)
    -- = magV (up .- p) < 10

      updateRock :: Rock -> [Rock]
      updateRock r@(Rock p s v)
      -- ��ɒe���������āA��̃T�C�Y��7��菬�����ꍇ�ɂ͏��ŁB
       | collidesWithBullet r && s < 7
            = []
      -- ��ɒe���������āA��̃T�C�Y��7���傫���ꍇ�ɂ͕���B
       | collidesWithBullet r && s > 7
            = splitRock r
      -- ��L�ȊO�̏ꍇ�A����timeStep�������ʒu���X�V�B
      -- ��ɒe���������āA��̃T�C�Y��7�̏ꍇ�́A�����Ɋ܂܂��B
       | otherwise
            = [Rock (restoreToScreen (p .+ timeStep .* v)) s v]

      updateBullet :: Bullet -> [Bullet]
      updateBullet (Bullet p v a)
        | a > 5
             = []
        | any (collidesWith p) rocks
             = []
        | otherwise
             = [Bullet (restoreToScreen (p .+ timeStep .* v)) v
                       (a + timeStep)]

      newShipPos :: PointInSpace
--      newShipPos = restoreToScreen (shipPos .+ timeStep .* shipV)
      newShipPos = restoreToScreen (shipPos)
  
--      newUFOPos :: PointInSpace
--      newUFOPos = restoreToScreen (ufoPos .+ timeStep .* (ufoV .+ (rotateV (pi/3) shipPos)))
  
splitRock :: Rock -> [Rock]
splitRock (Rock p s v) = [Rock p (s/2) (3 .* rotateV (pi/3)  v)
                         ,Rock p (s/2) (3 .* rotateV (-pi/3) v) ]
 
-- destroyUFO :: UFO -> Maybe a
-- destroyUFO (UFO p v) = Nothing

restoreToScreen :: PointInSpace -> PointInSpace
restoreToScreen (x,y) = (cycleCoordinates x, cycleCoordinates y)

cycleCoordinates :: (Ord a, Num a) => a -> a
cycleCoordinates x
    | x < (-400) = 800+x
    | x > 400    = x-800
    | otherwise  = x

drawWorld :: AsteroidWorld -> Picture

drawWorld GameOver 
   = pictures [scale 0.3 0.3 . translate (-400) 0 
               . color white . text $ "Game Over!",
           scale 0.1 0.1 . translate (-1150) (-550)
           . color white . text $ 
           "Click right mousebutton to restart"]

-- drawWorld (Play rocks (Ship (x,y) (vx,vy)) (UFO (ux,uy) (uvx, uvy)) bullets)
drawWorld (Play rocks (Ship (x,y) (vx,vy)) bullets score)
--  = pictures [ship, asteroids, ufo, shots]
  = pictures [ship, asteroids, shots, pts]
   where
--    ship      = color white (pictures [translate x y (circle 10)])
--    ship      = color white (pictures [translate x y (rotate (180*(atan (vx/vy))/pi) (line (shipShape)))])
    ship      = color white (pictures [translate x y (rotate (180*(atan2 vx vy)/pi) (line (shipShape)))])
    asteroids = pictures [(color white (line (asteroidShape x y s)))
                         | Rock   (x,y) s _ <- rocks]
--    ufo       = color green (pictures [translate ux uy (circle 10)])
    shots     = pictures [translate x y (color white (circle 2))
                         | Bullet (x,y) _ _ <- bullets]
--  pts       = pictures [translate (-400) (-400) (text $ "0") ]   
    pts          = pictures [ translate (-200) (200) (scale 0.3 0.3 (color white  (text $ "0"))) ]

-- 2019-06-05
shipShape :: [Point]
shipShape = [(0, -10), (-5, 10), (5, 10), (0, -10)]
                
-- 2019-05-29
asteroidShape :: Float -> Float -> Float -> [Point]
asteroidShape x y s = [(x+0.7*s,y+0.5*s), (x-0.1*s,y+0.8*s),
                       (x-0.7*s,y+0.6*s), (x-0.9*s,y-0.1*s),
                       (x-0.7*s,y-0.9*s), (x+0.0*s,y-0.7*s),
                       (x+0.6*s,y-0.8*s), (x+0.9*s,y-0.2*s),
                       (x+0.5*s,y+0.1*s), (x+0.7*s,y+0.5*s)]

handleEvents :: Event -> AsteroidWorld -> AsteroidWorld

-- new eventhandler for restarting --
handleEvents (EventKey (MouseButton RightButton) Down _ _) GameOver
          = initialWorld


handleEvents (EventKey (MouseButton LeftButton) Down _ clickPos)
--             (Play rocks (Ship shipPos shipVel) ufo bullets)
--             = Play rocks (Ship shipPos newVel) ufo
             (Play rocks (Ship shipPos shipVel) bullets score)
             = Play rocks (Ship shipPos newVel) 
                          (newBullet : bullets)
                          score
 where
     newBullet = Bullet shipPos
                        ((-150) .* norm (shipPos .- clickPos))
                        0
--     newVel    = shipVel .+ (50 .* norm (shipPos .- clickPos))
     newVel    = (50 .* norm (shipPos .- clickPos))

handleEvents _ w = w

type PointInSpace = (Float, Float)

(.-) , (.+) :: PointInSpace -> PointInSpace -> PointInSpace
(x,y) .- (u,v) = (x-u,y-v)
(x,y) .+ (u,v) = (x+u,y+v)

(.*) :: Float -> PointInSpace -> PointInSpace
s .* (u,v) = (s*u,s*v)

infixl 6 .- , .+
infixl 7 .*

norm :: PointInSpace -> PointInSpace
norm (x,y) = let m = magV (x,y) in (x/m,y/m)

magV :: PointInSpace -> Float
magV (x,y) = sqrt (x**2 + y**2)

limitMag :: Float -> PointInSpace -> PointInSpace
limitMag n pt = if (magV pt > n)
                  then n .* (norm pt)
                  else pt

rotateV :: Float -> PointInSpace -> PointInSpace
rotateV r (x,y) = (x * cos r - y * sin r
                  ,x * sin r + y * cos r)

-- Main function that launches the game --
main = play
         (InWindow "Asteroids!" (550,550) (20,20))
         black
         24
         initialWorld
         drawWorld
         handleEvents
         simulateWorld
