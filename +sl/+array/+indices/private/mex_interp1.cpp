#include <cstring>
#include <string>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include "mex.h"
#include "matrix.h"

#include "MexSupport.h"

using namespace std;
void print_usage();

void mexFunction( int nlhs, mxArray **plhs, int nrhs, const mxArray *prhs[]) {

    int xOffset = 1;
    if( (nrhs==2) ||
            (nrhs==3 && mxIsChar(prhs[0]))  ||
            (nrhs==4 && !(mxIsChar(prhs[0]) || mxIsEmpty(prhs[0])) ||
             (nrhs==4 && strcmp((char*)mxGetPr(prhs[0]), "extrap")==0)) ) {
        xOffset = 0;
    }

    bool ppOutput = false;
    // PP = INTERP1(X,Y,METHOD,"pp")
    if( nrhs>=4 && mxIsChar(prhs[0]) && strcmp("pp", (char*)mxGetPr(prhs[0])) == 0) {
        ppOutput = true;
        if (nrhs > 4) {
            mexErrMsgIdAndTxt("MATLAB:interp1:ppOutput",
                    "Use 4 inputs for PP=INTERP1(X,Y,METHOD,""pp"").");
        }
    }

    // Process Y in INTERP1(Y,) and INTERP1(X,Y,)
    int y_idx = 0 + xOffset;
    double* x = 0x0;
    double* y = mxGetPr(prhs[y_idx]);
    bool isvector_x = false;
    bool isvector_y = false;
    int nRowsY = mxGetM(prhs[y_idx]);
    int nColsY = mxGetN(prhs[y_idx]);

    // y may be an ND array, but collapse it down to a 2D yMat. If yMat is
    // a vector, it is a column vector.
    int ds     =  1;
    int prodDs =  1;
    int n      = -1;
    const mwSize* nDim = mxGetDimensions();
    if( nRowsY == 1 || nRowsY == 1){
        n      = nRowsY*nColsY; // numel
        ds     = 1;
        prodDs = 1;
        isvector_y = true;
    }
    else {
        n      = nRowsY;
        ds     = nColsY;
        prodDs = prod(ds);
        // CAA TODO this transforms ND-Arrays into 2D arrays, might be OBE
        //yMat   = reshape(y, [n prodDs]);
    }

    // Process X in INTERP1(X,Y,), or supply default for INTERP1(Y,)
    int nRowsX = -1;
    int nColsX = -1;
    if( xOffset ) {
        x_idx  = xOffset - 1;
        x      = mxGetPr(prhs[x_idx]);
        nRowsX = mxGetM(prhs[x_idx]);
        nColsX = mxGetN(prhs[x_idx]); 
        if( nRowsX > 1 || nRowsY > 1) {
            mexErrMsgIdAndTxt("MATLAB:interp1:Xvector", "X must be a vector.");
        }
        if( nRowsX*nColsX != n) {
            if (isvector_y) {
                mexErrMsgIdAndTxt("MATLAB:interp1:YInvalidNumRows",
                        "X and Y must be of the same length.")
            }
            else {
                mexErrMsgIdAndTxt("MATLAB:interp1:YInvalidNumRows",
                        "LENGTH(X) and SIZE(Y,1) must be the same.");
            }
        }
        // Prefer column vectors for x
        x = x;
    }
    else {
        // Note: This memory needs to be deallocated below
        x = mxMalloc(n*sizeof(double));
        for(int ii = 1; ii <= n; ii++)
            x[ii] = ii;;
    }
    double *xi;
    int nRowsXi = -1;
    int nColsXi = -1;
    
    int nRowsYi = -1;
    int nColsYi = -1;
    // Process XI in INTERP1(Y,XI,) and INTERP1(X,Y,XI,)
    // Avoid syntax PP = INTERP1(X,Y,METHOD,"pp")
    if( !ppOutput ){
        int xi_idx = 2+xOffset-1;
        xi      = prhs[xi_idx];
        nRowsXi = mxGetM(prhs[xi_idx]);
        nColsXi = mxGetN(prhs[xi_idx]);

        // The size of the output YI
        if (isvector_y) {
            // Y is a vector so size(YI) == size(XI)
            nRowsYi = nRowsXi;
            nColsYi = nColsXi;
        }
        else {
            if( nRowsXi == 1 && nColsXi == 1 ){
                // Y is not a vector but XI is
                nRowsYi = length(xi);
                nColsYi = ds;
            }
            else {
                // Both Y and XI are non-vectors
                nRowsYi = nRowsXi;
                nColsYi = nColsXi;
                // CAA TODO this might be broken!
                // siz_yi = [siz_xi ds];
            }
        }
    }

    if( xOffset && mxIsComplex(x) ){
        mexErrMsgIdAndTxt("MATLAB:interp1:ComplexX", "X should be a real vector.")
    }

    if (!ppOutput && mxIsComplex(xi)) {
        mexErrMsgIdAndTxt("MATLAB:interp1:ComplexInterpPts",
                "The interpolation points XI should be real.")
    }

    // Error check for NaN values in X and Y
    // check for NaN"s
    if( xOffset && (any(mxIsNaN(x))) ){
        mexErrMsgIdAndTxt("MATLAB:interp1:NaNinX", "NaN is not an appropriate value for X.");
    }

    // NANS are allowed as a value for F(X), since a function may be undefined
    // for a given value.
    if( any(mxIsNaN(yMat(:))) ){
        mexWarnMsgIdAndTxt("MATLAB:interp1:NaNinY",
                "NaN found in Y, interpolation at undefined values \n\t
                will result in undefined values.");
    }

    double *yi(0x0);
    if (n < 2) {
        if( ppOutput || !mxIsEmpty(xi) ){
            mexErrMsgIdAndTxt("MATLAB:interp1:NotEnoughPts",
                    "There should be at least two data points.")
        }
        else {
            
            yi = (double*)mxCalloc(nRowsYi*nColsYi*sizeof(double));
            MexSupport::assignToMxArray(yi, nRowsYi, nColsYi, plhs[0]);
            return
        }
    }

    // Process METHOD in
    // PP = INTERP1(X,Y,METHOD,"pp")
    // YI = INTERP1(Y,XI,METHOD,)
    // YI = INTERP1(X,Y,XI,METHOD,)
    // including explicit specification of the default by an empty input.
    string method;
    if( ppOutput ){
        if( mxIsEmpty(prhs[3])) {
            method = "linear";
        }
        else {
            method = mxGetString(prhs[3]);
        }
    }
    else {
        if( nrhs >= 3+xOffset && !mxIsEmpty(prhs[3+xOffset]) ){
            method = prhs[3+xOffset];
        }
        else {
            method = "linear";
        }
    }

    // The v5 option, "*method", asserts that x is equally spaced.
    int eqsp = (method[0] == "*");
    int method_offset = 0;
    if (eqsp)
        method_offset = 1;

    // INTERP1([X,]Y,XI,METHOD,"extrap") and INTERP1([X,]Y,Xi,METHOD,EXTRAPVAL)
    string extrapval;
    if( !ppOutput ){
        if( nrhs >= 4+xOffset ){
            extrapval = mxGetString(prhs[4+xOffset-1]);
        }
        else {
            switch( method[method_offset] ){
                case 's'
                    case 'p'
                    case 'c'
                    {
                        extrapval = "extrap";
                        break;
                    }
                default {
                    extrapval = "NaN";
                }
            }
        }
    }
    // Start the algorithm
    // We now have column vector x, column vector or 2D matrix yMat and
    // column vector xi.
    double h;
    bool repeatedx(false);
    bool nonincreasing(false);
    
    if( xOffset ){
        if( !eqsp ){
            double spacing = -1;
            for(int ii = 1; ii < nRowsX*nColsX; ii++)
            {
                h = x[ii]-x[ii-1];
                if( h[ii] < 0)
                    nonincreasing = true;
                if( h[ii] == 0)
                {
                    repeatedx = true;
                }
                if (spacing > 0 && h[ii] != spacing) 
                {
                    eqsp = 0;
                }
                else if (spacing < 0)
                {
                    spacing = h[ii];
                }
                // CAA TODO
                //infinite check, set eqsp to 0
            }
        }
        if( eqsp ){
            h = (x[n-1]-x[0])/[n-1];
        }
    }
    else {
        h    = 1;
        eqsp = 1;
    }

    if (nonincreasing  ){
        mexErrMsgIdAndTxt("MATLAB:interp1:NonIncreasingValuesX",
                "The values of X must be monotonically increasing.");
        sort(x,x+nRowsX*nColsX);
        /*
        [x, p] = sort(x);
        yMat = yMat(p, :);
        if( eqsp ){
            h = -h;
        }
        else {
            h = diff(x);
        }
        */
    }

    if( repeatedx) {
        mexErrMsgIdAndTxt("MATLAB:interp1:RepeatedValuesX",
                "The values of X should be distinct.");
    }

    // PP = INTERP1(X,Y,METHOD,"pp")
    if( nrhs==4 && mxIsChar(prhs[3]) && isequal("pp", prhs[3]) ){
        // obtain pp form of output
        // CAA TODO
        // MexSupport::assignToMxArray(mu, numel, 1, plhs[0]);
       
        /*
        pp = ppinterp;
        varargout[1] = pp;
        */
        return;
    }

    // Interpolate
    int numelXi = nRowsXi*nColsXi;
    double* p(0x0);
    double*yiMat(0x0);
    switch( method(1) ){
        case "s":  // "spline"
        {
            // spline is oriented opposite to interp1
            //yiMat = spline(x.',yMat.', xi.').;
            return;
            break;
        }
        case "c":
            case "p":  // "cubic" or "pchip"
            {
                // pchip is oriented opposite to interp1
                //yiMat = pchip(x.',yMat.', xi.').';
                return;
            }
        default // "nearest", "linear", "v5cubic"
        {
            yiMat = (double*)mxMalloc(numelXi*prodDs*sizeof(double));
            
            if( !eqsp && any(diff(xi) < 0)) {
                [xi, p] = sort(xi);
            }
            else {
                p = (double*)mxMalloc(numelXi*sizeof(double));
                for( int ii = 0; ii < numelXi; ii++)
                {
                    p[ii] = ii+1;
                }

            }
            

            // Find indices of subintervals, x(k) <= u < x(k+1),
            // or u < x(1) or u >= x(m-1).
            if( mxIsEmpty(xi) ){
                k = xi;
            }
            else if( eqsp ){
                k = min(max(1+floor((xi-x[0])/h), 1), n-1);
            }
            else {
                [~, k] = histc(xi, x);
                k(xi<x[0] | !isfinite[xi]) = 1;
                k(xi>=x[n]) = n-1;
            }

            switch( method(1) ){
                case "n"  // "nearest"
                {
                    //i = find(xi >= (x[k]+x[k+1])/2);
                    for( int ii =0; ii++ ii < numelXi; ii++)
                    {

                    }
                    k[i] = k[i]+1;
                    yiMat[p, :] = yMat[k, :];
                    break;
                }
                case "l"  // "linear"
                {
                    if( eqsp ){
                        s = (xi - x[k])/h;
                    }
                    else {
                        s = (xi - x[k])./h[k];
                    }
                    for(int iiP = 0; iiP < nRowsXi*nRowsYi; iiP++)
                    {
                        for( int jj = 0; jj < prodDs; jj++){
                            yiMat[iiP*nRowsXi, j] = yMat[k, j] + s.*(yMat[k+1, j]-yMat[k, j]);
                        }
                    }
                    break;
                }
                case "v"  // "v5cubic"
                {
                    //extrapval = NaN;
                    if( eqsp ){
                        // Data are equally spaced
                        double s = (xi - x[k])/h;
                        double s2 = s.*s;
                        double s3 = s.*s2;
                        // Add extra points for first and last interval
                        /*
                           yMat = [3*yMat[1, :]-3*yMat[2, :]+yMat[3, :];
                           yMat;
                           3*yMat[n, :]-3*yMat[n-1, :]+yMat[n-2, :]];
                         */
                        for( int jj = 0; jj < prodDs; jj++)
                        {
                            yiMat[p, j] = (yMat[k, j].*(-s3+2*s2-s) +
                                    yMat[k+1, j].*(3*s3-5*s2+2) +
                                    yMat[k+2, j].*(-3*s3+4*s2+s) +
                                    yMat[k+3, j].*(s3-s2))/2;
                        }
                    }
                    else {
                        // Data are not equally spaced
                        // spline is oriented opposite to interp1
                        //yiMat = spline(x.',yMat.', xi.').';
                    }
                    break;
                }
                default {
                    mexErrMsgIdAndTxt("MATLAB:interp1:InvalidMethod", "Invalid method.")
                }
            }
        }
    }

    // Override extrapolation
    if( extrapval != "extrap") {
        if( extrapval != "NaN"){
            mexErrMsgIdAndTxt("MATLAB:interp1:InvalidExtrap", "Invalid extrap option.")
        }
        else if( !isscalar(extrapval) ){
            mexErrMsgIdAndTxt("MATLAB:interp1:NonScalarExtrapValue",
                    "EXTRAP option must be a scalar.")
        }
        if( p == 0x0 ){
            p = (double*)mxMalloc(numelXi*sizeof(double));
            for( int ii = 0; ii < numelXi; ii++)
            {
                p[ii] = ii+1;
            }
        }
        for(int ii = 0; ii < numelXi; ii++)
        {
            if( xi[ii]<x[0] || xi[ii]>x[n];)
            {
                for( int jj = 0; jj < ; jj++)
                {
                  yiMat[p[ii], :] = extrapval;
                }
            }
        }
    }

    // Reshape result, possibly to an ND array
    // CAA TODO
    //yi = reshape(yiMat, siz_yi);
    //varargout[1] = yi;

    if(!xOffset)
    {
        // x was not an input argument
        mxFree(x);
    }
}
//-------------------------------------------------------------------------//
// //     function pp = ppinterp
// //         //PPINTERP ppform interpretation.
// //
// //         switch method(1)
// //             case "n" // nearest
// //                 breaks = [x(1);
// //                     (x(1:}-1)+x(2:}))/2;
// //                     x(})].";
// //                 coefs = yMat.";
// //                 pp = mkpp(breaks,coefs,ds);
// //             case "l" // linear
// //                 breaks = x.";
// //                 page1 = (diff(yMat)./repmat(diff(x),[1, prodDs])).";
// //                 page2 = (reshape(yMat(1:}-1,:),[n-1, prodDs])).";
// //                 coefs = cat(3,page1,page2);
// //                 pp = mkpp(breaks,coefs,ds);
// //             case [1] // pchip and cubic
// //                 pp = pchip(x.",reshape(yMat.",[ds, n]));
// //             case "s" // spline
// //                 pp = spline(x.",reshape(yMat.",[ds, n]));
// //             case "v" // v5cubic
// //                 b = diff(x);
// //                 if norm(diff(b),Inf) <= eps(norm(x,Inf))
// //                     // data are equally spaced
// //                     a = repmat(b,[1 prodDs]).";
// //                     yReorg = [3*yMat(1,:)-3*yMat(2,:)+yMat(3,:);
// //                         yMat;
// //                         3*yMat(n,:)-3*yMat(n-1,:)+yMat(n-2,:)];
// //                     y1 = yReorg(1:}-3,:).";
// //                     y2 = yReorg(2:}-2,:).";
// //                     y3 = yReorg(3:}-1,:).";
// //                     y4 = yReorg(4:},:).";
// //                     breaks = x.";
// //                     page1 = (-y1+3*y2-3*y3+y4)./(2*a.^3);
// //                     page2 = (2*y1-5*y2+4*y3-y4)./(2*a.^2);
// //                     page3 = (-y1+y3)./(2*a);
// //                     page4 = y2;
// //                     coefs = cat(3,page1,page2,page3,page4);
// //                     pp = mkpp(breaks,coefs,ds);
// //                 else
// //                     // data are not equally spaced
// //                     pp = spline(x.",reshape(yMat.",[ds, n]));
// //                 }
// //             otherwise
// //                 mexErrMsgIdAndTxt("MATLAB:interp1:ppinterp:UnknownMethod",
// //                     "Unrecognized method.");
// //         }
// //
// //         // Even if method is "spline" or "pchip", we still need to record that the
// //         // input data Y was oriented according to INTERP1"s rules.
// //         // Thus PPVAL will return YI oriented according to INTERP1"s rules and
// //         // YI = INTERP1(X,Y,XI,METHOD) will be the same as
// //         // YI = PPVAL(INTERP1(X,Y,METHOD,"pp"),XI)
// //         pp.orient = "first";
// //     } // PPINTERP

// } // INTERP1
// }
