-- 2019-05-29
-- Asteroids Game ���

-- ���LURL�̎�������͂����D
-- https://github.com/nikoheikkila/asteroids

-- 2021-04-27
-- �����ŃQ�[��������̂��Ƃ����₢�ŁC���̃R�[�h���v���o��
-- ���@�Ɠ_���\�����C������

-- Gloss���C�u�����x�[�X�Ő݌v����Ă���D
module Main where
import Graphics.Gloss
import Graphics.Gloss.Interface.Pure.Game
import Graphics.Gloss.Interface.Pure.Simulate
import Graphics.Gloss.Interface.Pure.Display

-- AsteroidWorld�Ƃ����Q�[�����E�̒�`�D
-- data AsteroidWorld = Play [Rock] Ship UFO [Bullet] 
data AsteroidWorld = Play [Rock] Ship [Bullet] Score
                   | GameOver
                   deriving (Eq,Show)

-- Play�́CGloss���C�u�����̍\�z�q�D
-- [Rock]�͊���̃��X�g�D
-- Ship�͑D���D
-- [Bullet]�͒e���̃��X�g�D

type Velocity     = (Float, Float)  -- ���xVelocity�́C�P���xFloat�̃y�A�D
type Size         = Float           -- Size is Float
type Age          = Float           -- Age is Float
type Score       = Integer        -- Score is Integer

-- �D���Ship�́C���WPointInSpace�C���xVelocity����\���D
data Ship   = Ship   PointInSpace Velocity
    deriving (Eq,Show)
-- �e���Bullet�́C���WPointInSpace�C���xVelocity�C�N��Age����\���D
data Bullet = Bullet PointInSpace Velocity Age
    deriving (Eq,Show)
-- ����Rock�́C���WPointInSpace�C�T�C�YSize�C���xVelocity����\���D
data Rock   = Rock   PointInSpace Size Velocity
    deriving (Eq,Show)

-- ���������ꂽ�Q�[�����E��ԋp����֐�initialWorld���`�D
initialWorld :: AsteroidWorld
initialWorld = Play
                   [Rock (150,150)  45 (2,6)
                   ,Rock (-45,201)  45 (13,-8)
                   ,Rock (45,22)    25 (-2,8)
                   ,Rock (-210,-15) 30 (-2,-8)
                   ,Rock (-45,-201) 25 (8,2)
                   ] -- The default rocks
                   (Ship (0,0) (0,0)) -- The initial ship
                   [] -- The initial bullets (none)
                   0

-- �Q�[�����E���V�~�����[�g����֐�simulateWorld���`�D
-- ��1����Float�́C�o�ߎ���timeStep���w��D
-- ��2����AsteroidWorld�́C�����_�ł̃Q�[�����E���w��D
-- ��3����AsteroidWorld�́C���Ԍo�߂�����̃Q�[�����E���ԋp�D

simulateWorld :: Float -> (AsteroidWorld -> AsteroidWorld)

-- �Q�[���I�[�o�[�̏ꍇ�́C�Q�[���I�[�o��ԋp�D
simulateWorld _        GameOver          = GameOver

simulateWorld timeStep (Play rocks (Ship shipPos shipV) bullets score)
  | any (collidesWith shipPos) rocks = GameOver
  | otherwise = Play (concatMap updateRock rocks)
                              (Ship newShipPos shipV)
                              (concat (map updateBullet bullets))
                              (score + sum (map updateScore rocks))
  where
    -- ���Wp���C��Rock�ɏՓ˂������ۂ���ԋp�D
    -- ����Wrp�����T�C�Ys�������ꂽ�̈�i�~�j�ɁC���Wp���܂܂�邩�ۂ���ԋp�D
      collidesWith :: PointInSpace -> Rock -> Bool
      collidesWith p (Rock rp s _)
       = magV (rp .- p) < s

    -- �����ꂩ�̒e���Wbp���C��r�ɏՓ˂������ۂ���ԋp�D
      collidesWithBullet :: Rock -> Bool
      collidesWithBullet r
       = any (\(Bullet bp _ _) -> collidesWith bp r) bullets

      updateRock :: Rock -> [Rock]
      updateRock r@(Rock p s v)
      -- ��ɒe���������āC��̃T�C�Y��7��菬�����ꍇ�ɂ͏��ŁD
       | collidesWithBullet r && s < 7
            = []
      -- ��ɒe���������āC��̃T�C�Y��7���傫���ꍇ�ɂ͕���D
       | collidesWithBullet r && s > 7
            = splitRock r
      -- ��L�ȊO�̏ꍇ�C����timeStep�������ʒu���X�V�D
      -- ��ɒe���������āC��̃T�C�Y��7�̏ꍇ�́C�����Ɋ܂܂��D
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
--      �e�𔭎˂��Ă������œ����Ȃ�
--      newShipPos = restoreToScreen (shipPos .+ timeStep .* shipV)
      newShipPos = restoreToScreen (shipPos)
  
      updateScore :: Rock -> Integer
      updateScore r@(Rock p s v)
      -- ��ɒe���������āC��̃T�C�Y��7��菬�����ꍇ�ɂ͏��ŁD
       | collidesWithBullet r && s < 7
            = 500
      -- ��ɒe���������āC��̃T�C�Y��7���傫���ꍇ�ɂ͕���D
       | collidesWithBullet r && s > 7
            = 100
      -- ��L�ȊO�̏ꍇ�C����timeStep�������ʒu���X�V�D
      -- ��ɒe���������āC��̃T�C�Y��7�̏ꍇ�́C�����Ɋ܂܂��D
       | otherwise
            = 0

splitRock :: Rock -> [Rock]
splitRock (Rock p s v) = [Rock p (s/2) (3 .* rotateV (pi/3)  v)
                         ,Rock p (s/2) (3 .* rotateV (-pi/3) v) ]
 
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

drawWorld (Play rocks (Ship (x,y) (vx,vy)) bullets score)
  = pictures [ship, asteroids, shots, pts]
   where
--    ship      = color white (pictures [translate x y (circle 10)])
    ship      = color white (pictures [translate x y (rotate (180*(atan2 vx vy)/pi) (line (shipShape)))])
    asteroids = pictures [(color white (line (asteroidShape x y s)))
                         | Rock   (x,y) s _ <- rocks]
    shots     = pictures [translate x y (color white (circle 2))
                         | Bullet (x,y) _ _ <- bullets]
    pts          = pictures [ translate (-200) (200) (scale 0.3 0.3 (color white  (text $ (show score)))) ]

-- 2019-06-05: ���@�L�����N�^
shipShape :: [Point]
shipShape = [(0, -10), (-5, 10), (5, 10), (0, -10)]
                
-- 2019-05-29: ��L�����N�^
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
             (Play rocks (Ship shipPos shipVel) bullets score)
             = Play rocks (Ship shipPos newVel) 
                          (newBullet : bullets)
                          (score+10)
 where
     newBullet = Bullet shipPos
                        ((-150) .* norm (shipPos .- clickPos))
                        0
     -- �����̖@���Œe�̑��x�ɂ����@�̑��x���e��
     -- newVel    = shipVel .+ (50 .* norm (shipPos .- clickPos))
     newVel    = (50 .* norm (shipPos .- clickPos))

handleEvents _ w = w

-- 2D���W�������֐����C�u����
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

-- Graphics.Gloss.Interface.
-- Pure.Game: ���[���h�𐧌�/�`�悷��֐��������ȏꍇ
-- IO.Game: ���[���h�𐧌�/�`�悷��֐���IO���i�h�̏ꍇ

         
