//
//  SIMDUtils.swift
//  drawLoop
//
//  Created by Rishabh Natarajan on 14/09/22.
//


import simd

let maxBuffersCount : Int  = 3;

//TODO:- Change here while refactoring to Traingle Strip
let kQuadVertices: [SIMD4<Float>] = [
    SIMD4<Float>(-1.0, -1.0, 0.0, 1.0),
    SIMD4<Float>( 1.0, -1.0, 0.0, 1.0),
    SIMD4<Float>(-1.0,  1.0, 0.0, 1.0),
    SIMD4<Float>( 1.0, -1.0, 0.0, 1.0),
    SIMD4<Float>(-1.0,  1.0, 0.0, 1.0),
    SIMD4<Float>( 1.0,  1.0, 0.0, 1.0)]

//TODO:- Change here while refactoring to Traingle Strip
let kQuadTexCoords: [SIMD2<Float>] = [
    SIMD2<Float>(0.0, 1.0),
    SIMD2<Float>(1.0, 1.0),
    SIMD2<Float>(0.0, 0.0),
    SIMD2<Float>(1.0, 1.0),
    SIMD2<Float>(0.0, 0.0),
    SIMD2<Float>(1.0, 0.0)]


extension simd_float4x4 {

    static func ortho2d(width: Float, height: Float) -> simd_float4x4 {

        let sLength: Float = 1.0 / width
        let sHeight: Float = 1.0 / height

        var P: SIMD4 = SIMD4(repeating: Float(0.0))
        var Q: SIMD4 = SIMD4(repeating: Float(0.0))
        var R: SIMD4 = SIMD4(repeating: Float(0.0))
        var S: SIMD4 = SIMD4(repeating: Float(0.0))

        P.x = 2.0 * sLength
        P.y = 0.0
        P.z = 0.0
        P.w = -1.0

        Q.x = 0.0
        Q.y = 2.0 * sHeight
        Q.z = 0.0
        Q.w = -1.0

        R.x = 0.0
        R.y = 0.0
        R.z = -1.0
        R.w = 0.0

        S.x = 0.0
        S.y = 0.0
        S.z = 0.0
        S.w = 1.0

        return simd_float4x4(P, Q, R, S)
    }
}

fileprivate func makeRotationMatrix(angle: Float) -> simd_float3x3 {
    let rows = [
        simd_float3( cos(angle), sin(angle), 0),
        simd_float3(-sin(angle), cos(angle), 0),
        simd_float3( 0,          0,          1)
    ]

    return simd_float3x3(rows: rows)
}

fileprivate func makeTranslationMatrix(tx: Float, ty: Float) -> simd_float3x3 {
    var matrix = matrix_identity_float3x3

    matrix[0, 2] = tx
    matrix[1, 2] = ty

    return matrix
}

func rotateAndTranslate(vector:SIMD2<Float>, by angle:Float, tx:Float, ty: Float) -> SIMD2<Float> {
    let positionVector = simd_float3(vector, 1)
    let rotated = positionVector*makeRotationMatrix(angle: angle)
    let translated = rotated*makeTranslationMatrix(tx: tx, ty: ty)
    return SIMD2<Float>(x:translated.x, y:translated.y)
}

func rotate(vector:SIMD2<Float>, by angle:Float) -> SIMD2<Float> {
    let positionVector = simd_float3(vector, 1)
    let rotated = positionVector*makeRotationMatrix(angle: angle)
    return SIMD2<Float>(x:rotated.x, y:rotated.y)
}

func translate(vector: SIMD2<Float>, tx:Float, ty: Float) -> SIMD2<Float> {
    let positionVector = simd_float3(vector, 1)
    let translationMatrix = makeTranslationMatrix(tx: tx, ty: ty)
    let translatedVector = positionVector * translationMatrix
    return SIMD2<Float>(x:translatedVector.x, y:translatedVector.y)
}
