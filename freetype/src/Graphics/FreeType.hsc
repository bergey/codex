{-# language PatternSynonyms #-}
{-# language QuasiQuotes #-}
{-# language TemplateHaskell #-}
{-# language ViewPatterns #-}
{-# language ForeignFunctionInterface #-}
{-# language RecordWildCards #-}
{-# language OverloadedStrings #-}
{-# language LambdaCase #-}
{-# language BlockArguments #-}
{-# options_ghc -Wno-redundant-constraints #-}

#include <ft2build.h>
#include FT_FREETYPE_H
#include FT_MODULE_H
#include FT_TYPES_H
#include FT_FONT_FORMATS_H
#include "hsc-struct.h"
#include "ft.h"
#let diff hsFrom, cTy, hsName, cField, hsTo = "%s_ :: Diff (%s) (%s)\n%s_ = Diff %lu\n{-# inline %s_ #-}", #hsName, #hsFrom, #hsTo, #hsName, (long) offsetof(cTy,cField), #hsName


-- |
-- Copyright :  (c) 2019 Edward Kmett
-- License   :  BSD-2-Clause OR Apache-2.0
-- Maintainer:  Edward Kmett <ekmett@gmail.com>
-- Stability :  experimental
-- Portability: non-portable
--

module Graphics.FreeType
( Error(..)
-- * Library
, Library
, LibraryRec
, init_library
, reference_library
, done_library
, property_set
, property_get
, new_uninitialized_library -- name mangled to keep users from reaching for it
, add_default_modules
, set_default_properties
, library_version
, library_version_string
, pattern FREETYPE_MAJOR
, pattern FREETYPE_MINOR
, pattern FREETYPE_PATCH

, Memory
, MemoryRec(..)
, AllocFunc, FreeFunc, ReallocFunc
, memory_user_
, memory_alloc_
, memory_free_
, memory_realloc_

-- * Faces

, Face
, FaceRec
, new_face
, new_memory_face
, face_family_name
, face_style_name
, reference_face
, done_face

-- ** Slots
, face_num_faces_
, face_index_
, FaceFlags(..)
, face_flags_
, FaceStyleFlags(..)
, face_style_flags_
, face_num_glyphs_
, face_num_fixed_sizes_
, face_num_charmaps_
, face_charmaps_
, face_ascender_
, face_descender_
, face_height_
, face_generic_
, face_glyph_
, face_units_per_EM_
, face_max_advance_width_
, face_max_advance_height_
, face_underline_position_
, face_underline_thickness_
, face_size_
, face_charmap_
, face_available_sizes_

-- ** Using the face
, get_font_format
, attach_file
, get_char_index
, get_first_char
, get_next_char
, get_name_index
, set_pixel_sizes
, set_transform

, SubGlyph
, SubGlyphRec
, SubGlyphFlags(..)
, SubGlyphInfo(..)
, face_get_subglyph_info

, LoadFlags(..)
, load_char
, load_glyph

, has_kerning
, KerningMode(..)
, get_kerning

, has_fixed_sizes
, has_color
, has_multiple_masters
, has_horizontal
, has_vertical
, has_glyph_names

, is_sfnt
, is_scalable
, is_fixed_width
, is_cid_keyed
, is_tricky
, is_named_instance
, is_variation

, Encoding(..)
, select_charmap

, CharMap
, CharMapRec(..)
, charmap_face_
, charmap_encoding_
, charmap_platform_id_
, charmap_encoding_id_

, GlyphMetrics(..)
, glyphmetrics_width_
, glyphmetrics_height_
, glyphmetrics_horiBearingX_
, glyphmetrics_horiBearingY_
, glyphmetrics_horiAdvance_
, glyphmetrics_vertBearingX_
, glyphmetrics_vertBearingY_
, glyphmetrics_vertAdvance_

-- * Glyphs
, Glyph
, GlyphRec(..)
, glyph_advance_
, glyph_format_
, glyph_clazz_
, glyph_library_

, GlyphFormat(..)
, new_glyph
, get_glyph

, IsGlyphRec, glyph_root
, glyph_copy
, glyph_transform
, glyph_to_bitmap

, GlyphBBoxMode(..)
, glyph_get_cbox

-- ** Bitmap Glyphs
, BitmapGlyph
, BitmapGlyphRec(..)
, bitmapglyph_root_
, bitmapglyph_top_
, bitmapglyph_left_
, bitmapglyph_bitmap_

, new_bitmapglyph
-- ** Outline Glyphs
, Outline(..)
, outline_contours_
, outline_flags_
, outline_points_
, outline_tags_
, outline_n_points_
, outline_n_contours_
, OutlineFlags(..)
, OutlineGlyph
, OutlineGlyphRec(..)
, outlineglyph_root_
, outlineglyph_outline_
, new_outlineglyph

-- * GlyphSlots
, GlyphSlot
, GlyphSlotRec
, face_glyph
, glyphslot_face
, SlotInternal
, SlotInternalRec
-- diffs
, glyphslot_glyph_index_
, glyphslot_generic_
, glyphslot_linearHoriAdvance_
, glyphslot_linearVertAdvance_
, glyphslot_bitmap_
, glyphslot_bitmap_left_
, glyphslot_bitmap_top_
, glyphslot_metrics_
, glyphslot_format_
, glyphslot_outline_
, glyphslot_num_subglyphs_
, glyphslot_subglyphs_
, glyphslot_control_data_
, glyphslot_control_len_
, glyphslot_lsb_delta_
, glyphslot_rsb_delta_
, glyphslot_other_
, glyphslot_internal_

, Bitmap(..)
, bitmap_width_
, bitmap_rows_
, bitmap_buffer_
, bitmap_pitch_
, bitmap_pixel_mode_
, bitmap_num_grays_
, bitmap_palette_mode_
, bitmap_palette_

, BitmapSize(..)
, bitmapsize_size_
, bitmapsize_height_
, bitmapsize_width_
, bitmapsize_x_ppem_
, bitmapsize_y_ppem_

, PixelMode(..)
, Pos

, RenderMode(..)
, render_glyph

, Size
, SizeRec(..)
, size_face_
, size_generic_
, size_metrics_
, size_internal_
, SizeMetrics(..)
, sizemetrics_ascender_
, sizemetrics_descender_
, sizemetrics_height_
, sizemetrics_x_scale_
, sizemetrics_y_scale_
, sizemetrics_x_ppem_
, sizemetrics_y_ppem_
, sizemetrics_max_advance_
, SizeInternalRec

, SizeRequest
, SizeRequestRec(..)
, sizerequest_type_
, sizerequest_width_
, sizerequest_height_
, sizerequest_vertResolution_
, sizerequest_horiResolution_
, SizeRequestType(..)

-- * Math
-- ** angles

, Angle
, pattern ANGLE_PI
, pattern ANGLE_2PI
, pattern ANGLE_PI2
, pattern ANGLE_PI4
, angleDiff

-- ** bounding boxes
, BBox(..)
, bbox_xMin_
, bbox_yMin_
, bbox_xMax_
, bbox_yMax_

-- ** fixed point

, Fixed(..)
-- , mulFix
-- , divFix

-- ** matices

, Matrix(..)
, matrixMultiply
, matrixInvert

-- ** vectors

, Vector(..)
, vectorTransform
-- , vectorUnit
-- , vectorRotate
-- , vectorLength
-- , vectorPolarize
-- , vectorFromPolar

, Generic(..)
, generic_data_
, generic_finalizer_
) where

import Control.Monad.IO.Class
import Data.ByteString as ByteString
import Data.ByteString.Internal as ByteString
import Data.Functor ((<&>))
import Data.Int
import Data.Version
import Data.Word
import Foreign.C.String
import Foreign.Marshal.Alloc
import Foreign.Marshal.Array
import Foreign.Marshal.Unsafe
import Foreign.Marshal.Utils
import Foreign.ForeignPtr
import Foreign.Ptr
import Foreign.Ptr.Diff
import Foreign.StablePtr
import Foreign.Storable
import Graphics.FreeType.Internal
import GHC.ForeignPtr
import qualified Language.C.Inline as C
import qualified Language.C.Inline.Unsafe as U
import Numeric.Fixed

C.context $ C.baseCtx <> C.bsCtx <> C.fptrCtx <> freeTypeCtx
C.include "<ft2build.h>"
C.verbatim "#include FT_FREETYPE_H"
C.verbatim "#include FT_GLYPH_H"
C.verbatim "#include FT_MODULE_H"
C.verbatim "#include FT_TYPES_H"
C.verbatim "#include FT_FONT_FORMATS_H"
C.include "ft.h"
C.include "HsFFI.h"

finalize_glyph :: FinalizerPtr GlyphRec
finalize_glyph = [C.funPtr|void finalize_face(FT_Glyph g) {
  FT_Library l = g->library;
  FT_Done_Glyph(g);
  FT_Done_Library(l);
}|]

-- you should use new_bitmap_glyph or new_outline_glyph, etc.
new_glyph :: MonadIO m => Library -> GlyphFormat -> m Glyph
new_glyph library format = liftIO do
  alloca \p -> do
    [U.exp|FT_Error {
      FT_New_Glyph($library:library,$(FT_Glyph_Format format),$(FT_Glyph * p))
    }|] >>= ok
    reference_library library
    peek p >>= newForeignPtr finalize_glyph

new_bitmapglyph :: MonadIO m => Library -> m BitmapGlyph
new_bitmapglyph library = act (inv glyph_root) <$> new_glyph library GLYPH_FORMAT_BITMAP

new_outlineglyph :: MonadIO m => Library -> m OutlineGlyph
new_outlineglyph library = act (inv glyph_root) <$> new_glyph library GLYPH_FORMAT_OUTLINE

class IsGlyphRec t where
instance IsGlyphRec BitmapGlyphRec
instance IsGlyphRec GlyphRec
instance IsGlyphRec OutlineGlyphRec

glyph_get_cbox :: (MonadIO m, IsGlyphRec t) => ForeignPtr t -> GlyphBBoxMode -> m BBox
glyph_get_cbox (act glyph_root -> glyph) (GlyphBBoxMode mode) = liftIO do
  alloca \p ->
    [U.block|void {
      FT_Glyph_Get_CBox($glyph:glyph,$(uint32_t mode),$(FT_BBox * p));
    }|] *> peek p

glyph_root :: IsGlyphRec t => Diff t GlyphRec
glyph_root = Diff 0

glyph_transform :: (MonadIO m, IsGlyphRec t) => ForeignPtr t -> Matrix -> Vector -> m ()
glyph_transform (act glyph_root -> glyph) m v = liftIO do
  [U.exp|FT_Error { FT_Glyph_Transform($glyph:glyph,$matrix:m,$vector:v) }|] >>= ok

get_glyph :: MonadIO m => GlyphSlot -> m Glyph
get_glyph slot = liftIO do
  alloca \p -> do
    [U.block|FT_Error {
      FT_GlyphSlot g = $glyph-slot:slot;
      FT_Error error = FT_Get_Glyph(g,$(FT_Glyph * p));
      if (!error) FT_Reference_Library(g->library);
      return error;
    }|] >>= ok
    peek p >>= newForeignPtr finalize_glyph

glyph_to_bitmap :: (MonadIO m, IsGlyphRec t) => ForeignPtr t -> RenderMode -> Vector -> Bool -> m BitmapGlyph
glyph_to_bitmap (act glyph_root -> glyph) mode origin (fromIntegral . fromEnum -> destroy) = liftIO do
  withForeignPtr glyph \pgr ->
    with pgr \pglyph -> do
      [U.exp|FT_Error { FT_Glyph_To_Bitmap($(FT_Glyph * pglyph),$(FT_Render_Mode mode),$vector:origin,$(FT_Bool destroy)) }|] >>= ok
      ngr <- peek pglyph
      act (inv glyph_root) <$>
        if pgr == ngr
        then pure glyph -- this is the old glyph
        else [C.block|void { FT_Reference_Library($(FT_Glyph ngr)->library); }|] *> newForeignPtr finalize_glyph ngr

glyph_copy :: (MonadIO m, IsGlyphRec t) => ForeignPtr t -> m (ForeignPtr t)
glyph_copy (act glyph_root -> glyph) = liftIO do
  alloca \p -> do
    [U.block|FT_Error {
      FT_Glyph g = $glyph:glyph;
      FT_Error error = FT_Glyph_Copy(g,$(FT_Glyph * p));
      if (!error) FT_Reference_Library(g->library);
      return error;
    }|] >>= ok
    result <- peek p
    act (inv glyph_root) <$> newForeignPtr finalize_glyph result

-- | Uses safe haskell calling convention in case of generic finalizers freeing haskell objects
finalize_face :: FinalizerPtr FaceRec
finalize_face = [C.funPtr|void finalize_face(FT_Face f) {
  FT_Library lib = f->glyph->library;
  FT_Done_Face(f);
  FT_Done_Library(lib);
}|]

-- | Uses safe haskell calling convention in case of generic finalizers freeing haskell objects
finalize_memory_face :: FinalizerEnvPtr () FaceRec
finalize_memory_face = [C.funPtr|void finalize_memory_face(void * stable_ptr, FT_Face f) {
  FT_Library lib = f->glyph->library;
  FT_Done_Face(f);
  hs_free_stable_ptr(stable_ptr);
  FT_Done_Library(lib);
}|]

-- | Uses the generic data facility to hold on to a reference to the library.
--
-- This ensures that we can free things in order.
new_face :: MonadIO m => Library -> FilePath -> Int -> m Face
new_face library path (fromIntegral -> i) = liftIO do
  alloca \p -> do
    [U.exp|FT_Error {
      FT_New_Face($library:library,$str:path,$(FT_Long i),$(FT_Face * p))
    }|] >>= ok
    reference_library library
    peek p >>= newForeignPtr finalize_face

new_memory_face :: MonadIO m => Library -> ByteString -> Int -> m Face
new_memory_face library bs@(PS bsfp _ _) (fromIntegral -> i) = liftIO do
  alloca \p -> do
    [U.exp|FT_Error {
      FT_New_Memory_Face($library:library,$bs-ptr:bs,$bs-len:bs,$(FT_Long i),$(FT_Face * p))
    }|] >>= ok
    reference_library library
    facePtr <- peek p
    case bsfp of
      -- 'fast' path
      ForeignPtr _ (PlainPtr mba) -> do
        -- hack together a MallocPtr that shares our MutableByteArray#
        newForeignPtr finalize_face facePtr <&> \case
          ForeignPtr addr (PlainForeignPtr finalizers) -> ForeignPtr addr (MallocPtr mba finalizers)
          _ -> error "new_memory_face: the impossible happened. newForeignPtr did not return a PlainForeignPtr"
      -- 'sane' path
      _ -> do
        stable <- newStablePtr bsfp
        newForeignPtrEnv finalize_memory_face (castStablePtrToPtr stable) facePtr

-- | Add a reference to a face
--
-- For the most part this should already be done for you through the API provided in Haskell,
-- but you may need this if you transfer the face to another library.
reference_face :: MonadIO m => Face -> m ()
reference_face face = liftIO do
  [U.exp|FT_Error { FT_Reference_Face($face:face)}|] >>= ok

-- | Remove a reference to a face
--
-- For the most part this should already be done for you through the API provided in Haskell,
-- but you may need this if you claim ownership of a face from another library.
done_face :: MonadIO m => Face -> m ()
done_face face = liftIO do
  [C.exp|FT_Error { FT_Done_Face($face:face) }|] >>= ok
  -- safe haskell call because it may free the generic, which might hold onto haskell data

get_char_index :: MonadIO m => Face -> Word32 -> m Word32
get_char_index face c = liftIO [U.exp|FT_UInt { FT_Get_Char_Index($face:face,$(FT_ULong c)) }|]

-- | Returns the charmap's first code and the glyph index of the first character code, 0 if the charmap is empty.
get_first_char :: MonadIO m => Face -> m (Word32, Word32)
get_first_char face = liftIO do
  alloca \agindex ->
    (,) <$> [U.exp|FT_UInt { FT_Get_First_Char($face:face,$(FT_UInt * agindex)) }|] <*> peek agindex

get_next_char :: MonadIO m => Face -> Word32 -> m (Word32, Word32)
get_next_char face c = liftIO do
  alloca \agindex ->
    (,) <$> [U.exp|FT_UInt { FT_Get_Next_Char($face:face,$(FT_ULong c),$(FT_UInt * agindex)) }|] <*> peek agindex

-- | Normally this is used to read additional information for the face object, such as attaching an AFM file that comes
-- with a Type 1 font to get the kerning values and other metrics.
attach_file :: MonadIO m => Face -> FilePath -> m ()
attach_file face path = liftIO do [U.exp|FT_Error { FT_Attach_File($face:face,$str:path) }|] >>= ok

set_pixel_sizes :: MonadIO m => Face -> Int -> Int -> m ()
set_pixel_sizes face (fromIntegral -> pixel_width) (fromIntegral -> pixel_height) = liftIO do
  [U.exp|FT_Error { FT_Set_Pixel_Sizes($face:face,$(FT_UInt pixel_width),$(FT_UInt pixel_height)) }|] >>= ok

get_name_index :: MonadIO m => Face -> ByteString -> m Word32
get_name_index face name = liftIO [U.exp|FT_UInt { FT_Get_Name_Index($face:face,$bs-cstr:name) }|]

load_char :: MonadIO m => Face -> Word32 -> LoadFlags -> m ()
load_char face char_code (LoadFlags load_flags) = liftIO do
  [U.exp|FT_Error { FT_Load_Char($face:face,$(FT_ULong char_code),$(FT_Int32 load_flags)) }|] >>= ok

load_glyph :: MonadIO m => Face -> Word32 -> LoadFlags -> m ()
load_glyph face glyph_index (LoadFlags load_flags) = liftIO do
  [U.exp|FT_Error { FT_Load_Glyph($face:face,$(FT_ULong glyph_index),$(FT_Int32 load_flags)) }|] >>= ok

-- | Returns whether the face object contains kerning data that can be accessed with 'get_kerning'
has_fixed_sizes :: Face -> Bool
has_fixed_sizes face = [U.pure|int { FT_HAS_FIXED_SIZES($face:face) }|] /=0

--face_fixed_sizes :: MonadIO m => Face -> m (Maybe [BitmapSize])
--face_fixed_sizes = liftIO $ withForeignPtr

-- | Returns whether the face object contains kerning data that can be accessed with 'get_kerning'
has_kerning :: Face -> Bool
has_kerning face = [U.pure|int { FT_HAS_KERNING($face:face) }|] /=0

get_kerning :: MonadIO m => Face -> Word32 -> Word32 -> KerningMode -> m Vector
get_kerning face left_glyph right_glyph (KerningMode kern_mode) = liftIO do
  alloca \v -> do
    [U.exp|FT_Error {
      FT_Get_Kerning(
        $face:face,
        $(FT_UInt left_glyph),
        $(FT_UInt right_glyph),
        $(FT_UInt kern_mode),
        $(FT_Vector * v)
      )
    }|] >>= ok
    peek v

-- | returns true whenever a face object contains horizontal metrics (this is true for all font formats though).
has_horizontal :: Face -> Bool
has_horizontal face = [U.pure|int { FT_HAS_HORIZONTAL($face:face) }|] /=0

-- | returns true whenever a face object contains real vertical metrics (and not only synthesized ones).
has_vertical :: Face -> Bool
has_vertical face = [U.pure|int { FT_HAS_VERTICAL($face:face) }|] /=0

-- | returns true whenever a face object contains some glyph names that can be accessed through FT_Get_Glyph_Name.
has_glyph_names :: Face -> Bool
has_glyph_names face = [U.pure|int { FT_HAS_GLYPH_NAMES($face:face) }|] /=0

-- | returns true whenever a face object contains a font whose format is based on the SFNT storage scheme. This usually means: TrueType fonts, OpenType fonts, as well as SFNT-based embedded bitmap fonts.
--
-- If this is true, all functions defined in FT_SFNT_NAMES_H and FT_TRUETYPE_TABLES_H are available.
is_sfnt :: Face -> Bool
is_sfnt face = [U.pure|int { FT_IS_SFNT($face:face) }|] /=0

-- | returns true whenever a face object contains a scalable font face (true for TrueType, Type 1, Type 42, CID, OpenType/CFF, and PFR font formats).
is_scalable :: Face -> Bool
is_scalable face = [U.pure|int { FT_IS_SCALABLE($face:face) }|] /=0

-- | returns true whenever a face object contains a font face that contains fixed-width (or ‘monospace’, ‘fixed-pitch’, etc.) glyphs.
is_fixed_width :: Face -> Bool
is_fixed_width face = [U.pure|int { FT_IS_FIXED_WIDTH($face:face) }|] /=0

-- | returns true whenever a face object contains a CID-keyed font. See the discussion of FT_FACE_FLAG_CID_KEYED for more details.
--
-- If this macro is true, all functions defined in FT_CID_H are available.
is_cid_keyed :: Face -> Bool
is_cid_keyed face = [U.pure|int { FT_IS_CID_KEYED($face:face) }|] /=0

-- | A macro that returns true whenever a face represents a ‘tricky’ font. See the discussion of FT_FACE_FLAG_TRICKY for more details.
is_tricky :: Face -> Bool
is_tricky face = [U.pure|int { FT_IS_TRICKY($face:face) }|] /=0

-- | returns true whenever a face object is a named instance of a GX or OpenType variation font.
--
-- [Since 2.9] Changing the design coordinates with FT_Set_Var_Design_Coordinates or FT_Set_Var_Blend_Coordinates does not influence the return value of this macro (only FT_Set_Named_Instance does that).
is_named_instance :: MonadIO m => Face -> m Bool
is_named_instance face = liftIO do [U.exp|int { FT_IS_NAMED_INSTANCE($face:face) }|] <&> (/=0)

-- | returns true whenever a face object has been altered by FT_Set_MM_Design_Coordinates, FT_Set_Var_Design_Coordinates, or  FT_Set_Var_Blend_Coordinates.
is_variation :: MonadIO m => Face -> m Bool
is_variation face = liftIO do [U.exp|int { FT_IS_VARIATION($face:face) }|] <&> (/=0)

-- | Select a given charmap by its encoding tag
select_charmap :: MonadIO m => Face -> Encoding -> m ()
select_charmap face encoding = liftIO $ [U.exp|FT_Error { FT_Select_Charmap($face:face,$(FT_Encoding encoding)) }|] >>= ok

-- | returns true whenever a face object contains tables for color glyphs.
has_color :: Face -> Bool
has_color face = [U.pure|int { FT_HAS_COLOR($face:face) }|] /=0

-- | Retrieves the face's associated glyph slot.
face_glyph :: Face -> GlyphSlot
face_glyph face = childPtr face [U.pure|FT_GlyphSlot { $face:face->glyph }|]

-- | Retrieves the glyphslot's associated face.
glyphslot_face :: GlyphSlot -> Face
glyphslot_face slot = childPtr slot [U.pure|FT_Face { $glyph-slot:slot->face }|]

-- | The number of faces in the font file. Some font formats can have multiple faces in a single font file.
#diff FaceRec, FT_FaceRec, face_num_faces, num_faces, Int32
-- | This field holds two different values. Bits 0-15 are the index of the face in the font file (starting with value 0). They are set to 0 if there is only one face in the font file.
--
-- [Since 2.6.1] Bits 16-30 are relevant to GX and OpenType variation fonts only, holding the named instance index for the current face index (starting with value 1; value 0 indicates font access without a named instance). For non-variation fonts, bits 16-30 are ignored. If we have the third named instance of face 4, say, face_index is set to 0x00030004.
--
-- Bit 31 is always zero (this is, face_index is always a positive value).
--
-- [Since 2.9] Changing the design coordinates with FT_Set_Var_Design_Coordinates or  FT_Set_Var_Blend_Coordinates does not influence the named instance index value (only  FT_Set_Named_Instance does that).
#diff FaceRec, FT_FaceRec, face_index, face_index, Int32
-- | A set of bit flags that give important information about the face; see FT_FACE_FLAG_XXX for the details.
#diff FaceRec, FT_FaceRec, face_flags, face_flags, FaceFlags
-- | The lower 16 bits contain a set of bit flags indicating the style of the face; see FT_STYLE_FLAG_XXX for the details.
--
-- [Since 2.6.1] Bits 16-30 hold the number of named instances available for the current face if we have a GX or OpenType variation (sub)font. Bit 31 is always zero (this is, style_flags is always a positive value). Note that a variation font has always at least one named instance, namely the default instance.
#diff FaceRec, FT_FaceRec, face_style_flags, style_flags, FaceStyleFlags
-- | The number of glyphs in the face. If the face is scalable and has sbits (see num_fixed_sizes), it is set to the number of outline glyphs.
--
-- For CID-keyed fonts (not in an SFNT wrapper) this value gives the highest CID used in the font.
#diff FaceRec, FT_FaceRec, face_num_glyphs, num_glyphs, Int32
-- | The number of bitmap strikes in the face. Even if the face is scalable, there might still be bitmap strikes, which are called ‘sbits’ in that case.
#diff FaceRec, FT_FaceRec, face_num_fixed_sizes, num_fixed_sizes, Int32
-- | The number of charmaps in the face.
#diff FaceRec, FT_FaceRec, face_num_charmaps, num_charmaps, Int32
-- | An array of the charmaps of the face.
#diff FaceRec, FT_FaceRec, face_charmaps, charmaps, Ptr CharMap

-- | The typographic ascender of the face, expressed in font units. For font formats not having this information, it is set to bbox.yMax. Only relevant for scalable formats.
#diff FaceRec, FT_FaceRec, face_ascender, ascender, Int16
-- | The typographic descender of the face, expressed in font units. For font formats not having this information, it is set to bbox.yMin. Note that this field is negative for values below the baseline. Only relevant for scalable formats.
#diff FaceRec, FT_FaceRec, face_descender, descender, Int16
-- | This value is the vertical distance between two consecutive baselines, expressed in font units. It is always positive. Only relevant for scalable formats.
--
-- If you want the global glyph height, use 'face_ascender' - 'face_descender'.
#diff FaceRec, FT_FaceRec, face_height, height, Int16
-- | The number of font units per EM square for this face. This is typically 2048 for TrueType fonts, and 1000 for Type 1 fonts. Only relevant for scalable formats.
#diff FaceRec, FT_FaceRec, face_units_per_EM, units_per_EM, Int16
-- | The maximum advance width, in font units, for all glyphs in this face. This can be used to make word wrapping computations faster. Only relevant for scalable formats.
#diff FaceRec, FT_FaceRec, face_max_advance_width, max_advance_width, Int16
-- | The maximum advance height, in font units, for all glyphs in this face. This is only relevant for vertical layouts, and is set to height for fonts that do not provide vertical metrics. Only relevant for scalable formats.
#diff FaceRec, FT_FaceRec, face_max_advance_height, max_advance_height, Int16
-- | The position, in font units, of the underline line for this face. It is the center of the underlining stem. Only relevant for scalable formats.
#diff FaceRec, FT_FaceRec, face_underline_position, underline_position, Int16
-- | The thickness, in font units, of the underline for this face. Only relevant for scalable formats.
#diff FaceRec, FT_FaceRec, face_underline_thickness, underline_thickness, Int16
-- | The current active size for this face.
#diff FaceRec, FT_FaceRec, face_size, size, Size
-- | The face's associated glyph slot(s).
#diff FaceRec, FT_FaceRec, face_glyph, glyph, Ptr GlyphSlotRec
-- | The current active charmap for this face.
#diff FaceRec, FT_FaceRec, face_charmap, charmap, CharMap
-- | An array of 'BitmapSize' for all bitmap strikes in the face. It is set to NULL if there is no bitmap strike.
--
-- Note that FreeType tries to sanitize the strike data since they are sometimes sloppy or incorrect, but this can easily fail.
#diff FaceRec, FT_FaceRec, face_available_sizes, available_sizes, Ptr BitmapSize
-- | A field reserved for client uses. See the 'Generic' type description.
#diff FaceRec, FT_FaceRec, face_generic, generic, Generic

-- | The face's family name. This is an ASCII string, usually in English, that describes the typeface's family (like @Times New Roman@, @Bodoni@, @Garamond@, etc). This is a least common denominator used to list fonts. Some formats (TrueType & OpenType) provide localized and Unicode versions of this string. Applications should use the format-specific interface to access them. Can be NULL (e.g., in fonts embedded in a PDF file).
--
-- In case the font doesn't provide a specific family name entry, FreeType tries to synthesize one, deriving it from other name entries.
face_family_name :: Face -> Maybe String
face_family_name face = unsafeLocalState $ maybePeek peekCString [U.pure|const char * { $face:face->family_name }|]

-- | The face's style name. This is an ASCII string, usually in English, that describes the typeface's style (like @Italic@, @Bold@, @Condensed@, etc). Not all font formats provide a style name, so this field is optional, and can be set to NULL. As for 'face_family_name', some formats provide localized and Unicode versions of this string. Applications should use the format-specific interface to access them.
face_style_name :: Face -> Maybe String
face_style_name face = unsafeLocalState $ maybePeek peekCString [U.pure|const char * { $face:face->style_name }|]

-- | [Since 2.10] The glyph index passed as an argument to 'load_glyph' while initializing the glyph slot.
#diff GlyphSlotRec, FT_GlyphSlotRec, glyphslot_glyph_index, glyph_index, Word32
-- | A typeless pointer unused by the FreeType library or any of its drivers. It can be used by client applications to link their own data to each glyph slot object.
#diff GlyphSlotRec, FT_GlyphSlotRec, glyphslot_generic, generic, Generic
-- | The metrics of the last loaded glyph in the slot. The returned values depend on the last load flags (see the 'load_glyph' API function) and can be expressed either in 26.6 fractional pixels or font units.
--
-- Note that even when the glyph image is transformed, the metrics are not.
#diff GlyphSlotRec, FT_GlyphSlotRec, glyphslot_metrics, metrics, GlyphMetrics
-- | The advance width of the unhinted glyph. Its value is expressed in 16.16 fractional pixels, unless  'LOAD_LINEAR_DESIGN' is set when loading the glyph. This field can be important to perform correct WYSIWYG layout. Only relevant for outline glyphs.
#diff GlyphSlotRec, FT_GlyphSlotRec, glyphslot_linearHoriAdvance, linearHoriAdvance, Fixed
-- The advance height of the unhinted glyph. Its value is expressed in 16.16 fractional pixels, unless  'LOAD_LINEAR_DESIGN' is set when loading the glyph. This field can be important to perform correct WYSIWYG layout. Only relevant for outline glyphs.
#diff GlyphSlotRec, FT_GlyphSlotRec, glyphslot_linearVertAdvance, linearVertAdvance, Fixed
-- | This field indicates the format of the image contained in the glyph slot. Typically 'GLYPH_FORMAT_BITMAP', 'GLYPH_FORMAT_OUTLINE', or 'GLYPH_FORMAT_COMPOSITE', but other values are possible.
#diff GlyphSlotRec, FT_GlyphSlotRec, glyphslot_format, format, GlyphFormat
-- | This field is used as a bitmap descriptor. Note that the address and content of the bitmap buffer can change between calls of 'load_glyph' and a few other functions.
#diff GlyphSlotRec, FT_GlyphSlotRec, glyphslot_bitmap, bitmap, Bitmap
-- | The bitmap's left bearing expressed in integer pixels.
#diff GlyphSlotRec, FT_GlyphSlotRec, glyphslot_bitmap_left, bitmap_left, Int32
-- | The bitmap's top bearing expressed in integer pixels. This is the distance from the baseline to the top-most glyph scanline, upwards y coordinates being positive.
#diff GlyphSlotRec, FT_GlyphSlotRec, glyphslot_bitmap_top, bitmap_top, Int32
-- | The outline descriptor for the current glyph image if its format is 'GLYPH_FORMAT_OUTLINE'. Once a glyph is loaded, outline can be transformed, distorted, emboldened, etc. However, it must not be freed.
#diff GlyphSlotRec, FT_GlyphSlotRec, glyphslot_outline, outline, Outline
-- | The number of subglyphs in a composite glyph. This field is only valid for the composite glyph format that should normally only be loaded with the 'LOAD_NO_RECURSE' flag.
#diff GlyphSlotRec, FT_GlyphSlotRec, glyphslot_num_subglyphs, num_subglyphs, Word32
-- | An array of subglyph descriptors for composite glyphs. There are num_subglyphs elements in there. Currently internal to FreeType.
#diff GlyphSlotRec, FT_GlyphSlotRec, glyphslot_subglyphs, subglyphs, SubGlyph
-- | Certain font drivers can also return the control data for a given glyph image (e.g. TrueType bytecode, Type 1 charstrings, etc.). This field is a pointer to such data; it is currently internal to FreeType.
#diff GlyphSlotRec, FT_GlyphSlotRec, glyphslot_control_data, control_data, Ptr ()
-- | This is the length in bytes of the control data. Currently internal to FreeType.
#diff GlyphSlotRec, FT_GlyphSlotRec, glyphslot_control_len, control_len, Int32
-- | The difference between hinted and unhinted left side bearing while auto-hinting is active. Zero otherwise.
#diff GlyphSlotRec, FT_GlyphSlotRec, glyphslot_lsb_delta, lsb_delta, Pos
-- | The difference between hinted and unhinted right side bearing while auto-hinting is active. Zero otherwise.
#diff GlyphSlotRec, FT_GlyphSlotRec, glyphslot_rsb_delta, rsb_delta, Pos
-- | Reserved.
#diff GlyphSlotRec, FT_GlyphSlotRec, glyphslot_other, other, Ptr ()
#diff GlyphSlotRec, FT_GlyphSlotRec, glyphslot_internal, internal, SlotInternal

-- | Retrieve a description of a given subglyph. Only use it if glyph->format is FT_GLYPH_FORMAT_COMPOSITE; an error is thrown otherwise.
face_get_subglyph_info :: MonadIO m => GlyphSlot -> Word32 -> m SubGlyphInfo
face_get_subglyph_info slot sub_index = liftIO $
  alloca \p_index ->
  alloca \p_flags ->
  alloca \p_arg1 ->
  alloca \p_arg2 ->
  alloca \p_transform -> do
    [C.exp|FT_Error {
      FT_Get_SubGlyph_Info(
        $glyph-slot:slot,
        $(FT_UInt sub_index),
        $(FT_Int * p_index),
        $(FT_UInt * p_flags),
        $(FT_Int * p_arg1),
        $(FT_Int * p_arg2),
        $(FT_Matrix * p_transform)
      )
    }|] >>= ok
    SubGlyphInfo
      <$> peek p_index
      <*> do SubGlyphFlags <$> peek p_flags
      <*> peek p_arg1
      <*> peek p_arg2
      <*> peek p_transform

-- | This is a suitable form for use as an X11 @FONT_PROPERTY@.
--
-- Possible values are @"TrueType"@, @"Type 1"@, @"BDF"@, @"PCF"@, @"Type 42"@, @"CID Type 1"@, @"CFF"@, @"PFR"@, and @"Windows FNT"@.
get_font_format :: Face -> ByteString
get_font_format face = unsafeLocalState $ ByteString.packCString [U.pure|const char * { FT_Get_Font_Format($face:face) }|]

-- | returns true whenever a face object contains some multiple masters. The functions provided by FT_MULTIPLE_MASTERS_H are then available to choose the exact design you want.
has_multiple_masters :: Face -> Bool
has_multiple_masters face = [U.pure|int { FT_HAS_MULTIPLE_MASTERS($face:face) }|] /=0

-- | Set the transformation that is applied to glyph images when they are loaded into a glyph slot through 'load_glyph'. The transformation is only applied to scalable image formats after the glyph has been loaded. It means that hinting is unaltered by the transformation and is performed on the character size given in the last call to 'set_char_size' or 'set_pixel_sizes'
--
-- Note that this also transforms the @face.glyph.advance@ field, but not the values in @face.glyph.metrics@.
set_transform :: MonadIO m => Face -> Matrix -> Vector -> m ()
set_transform face m v = liftIO [U.block|void { FT_Set_Transform($face:face,$matrix:m,$vector:v); }|]

-- * Library

-- this will use fixed memory allocation functions, but allows us to avoid the FT_Init_FreeType and FT_Done_FreeType global mess.
new_uninitialized_library :: MonadIO m => m Library
new_uninitialized_library = liftIO do
  alloca \p -> do
    [U.exp|FT_Error { FT_New_Library(&hs_memory,$(FT_Library * p))}|] >>= ok
    peek p >>= foreignLibrary

add_default_modules :: MonadIO m => Library -> m ()
add_default_modules library = liftIO [U.block|void { FT_Add_Default_Modules($fptr-ptr:(FT_Library library)); }|]

set_default_properties :: MonadIO m => Library -> m ()
set_default_properties library = liftIO [U.block|void { FT_Set_Default_Properties($fptr-ptr:(FT_Library library)); }|]

init_library :: MonadIO m => m Library
init_library = liftIO do
  l <- new_uninitialized_library
  add_default_modules l
  set_default_properties l
  return l

-- | Add a reference to a library.
--
-- For the most part this should already be done for you through the API provided in Haskell.
reference_library :: MonadIO m => Library -> m ()
reference_library library = liftIO do [U.exp|FT_Error { FT_Reference_Library($fptr-ptr:(FT_Library library))}|] >>= ok

-- | Remove a reference to a library, destroying the object if none remain.
--
-- For the most part this should already be done for you through the API provided in Haskell.
done_library :: MonadIO m => Library -> m ()
done_library library = liftIO do
  -- safe haskell call as this can free the generic
  [C.exp|FT_Error { FT_Done_Library($fptr-ptr:(FT_Library library))}|] >>= ok

-- | Useful when dynamic linking, as we can't rely on the patterns above which were determined at compile time.
library_version  :: MonadIO m => Library -> m Version
library_version library = liftIO do
  allocaArray 3 \ver -> do
    [C.block|void {
       FT_Int * ver = $(FT_Int * ver);
       FT_Library_Version($fptr-ptr:(FT_Library library),ver,ver+1,ver+2);
    }|]
    a <- peek ver
    b <- peek (advancePtr ver 1)
    c <- peek (advancePtr ver 2)
    pure $ makeVersion [fromIntegral a, fromIntegral b, fromIntegral c]

library_version_string :: MonadIO m => Library -> m String
library_version_string library = showVersion <$> library_version library

property_set :: MonadIO m => Library -> ByteString -> ByteString -> Ptr a -> m ()
property_set library module_name property_name (castPtr -> value) = liftIO do
  [U.exp|FT_Error { FT_Property_Set($fptr-ptr:(FT_Library library),$bs-cstr:module_name,$bs-cstr:property_name,$(void * value))}|] >>= ok

property_get :: MonadIO m => Library -> ByteString -> ByteString -> Ptr a -> m ()
property_get library module_name property_name (castPtr -> value) = liftIO do
  [U.exp|FT_Error { FT_Property_Get($fptr-ptr:(FT_Library library),$bs-cstr:module_name,$bs-cstr:property_name,$(void * value))}|] >>= ok

render_glyph :: MonadIO m => GlyphSlot -> RenderMode -> m ()
render_glyph slot render_mode = liftIO do
  [U.exp|FT_Error { FT_Render_Glyph($glyph-slot:slot,$(FT_Render_Mode render_mode)) }|] >>= ok
