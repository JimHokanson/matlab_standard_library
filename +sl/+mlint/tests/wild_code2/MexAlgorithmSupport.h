#ifndef MEX_ALGORITHM_SUPPORT_H
#define MEX_ALGORITHM_SUPPORT_H
#include "MexSupport.h"
#include "MexDataTypes.h"
#include <algorithm>
#include <functional>
#include <vector>

namespace  MexSupport {
// Rather than do an inplace sort on the data itself this operator sorts indirectly
// using the indices.
    template <class T>
            struct compare_by_index : public std::binary_function<int, int, bool> {
                const T* pData;
                compare_by_index()
                : pData(0x0)
                {}
                
                compare_by_index(const T* rpData)
                : pData(rpData)
                {}
                
                bool operator()(int ii, int jj);
            };
            
            template<class T>
                    bool compare_by_index<T>::operator()(int ii, int jj) {
                return pData[ii] < pData[jj];
    };
    template <class T>
            struct compare_by_index_stl: public std::binary_function<int, int, bool> {
                // CAA should make this a generic container 
                const std::vector<T>* pData;
                compare_by_index_stl()
                : pData(0x0)
                {}
                
                compare_by_index_stl(const std::vector<T>* rpData)
                : pData(rpData)
                {}
                
                bool operator()(int ii, int jj) const;
            };
            
            template<class T>
                    bool compare_by_index_stl<T>::operator()(int ii, int jj) const{
                return (*pData)[ii] < (*pData)[jj];
    };
    
    // This is the actual function to call
    template <class T>
            void sort_with_index(const T* pData, int N, T*& rpDataSort, MexUInt32*& rpIdx) {
        // sort inputs. requires deep copy of input
        
        if(rpDataSort != 0x0)
            mxFree(rpDataSort);
        
        if(rpIdx != 0x0)
            mxFree(rpIdx);
        
        rpDataSort = (T*)mxMalloc(sizeof(T)*N);
        rpIdx      = (MexUInt32*)mxMalloc(sizeof(MexUInt32)*N);
        
        // create a list of indices from 0 to number of events
        for(int ii = 0; ii < N; ii++)
            rpIdx[ii] = ii;
        
        // sort the list of indices using pData
        compare_by_index<T> comp_obj(pData);
        
        // use stable sort to perserve ordering of equal values, this
        // should be similar to matlab?
        std::sort(rpIdx, rpIdx + N, comp_obj);
        
        for(int ii = 0; ii < N; ii++)
            rpDataSort[ii] = pData[rpIdx[ii]];
    }
    
    template <class T>
        void sort_with_index(const std::vector<T>& rData,  std::vector<T>& rDataSort, std::vector<MexUInt32>& rIdx) {
        // sort inputs. requires deep copy of input
        int N = rData.size();
        if(!rDataSort.empty())
            rDataSort.clear();
        
        if(!rIdx.empty())
            rIdx.clear();
        
        rDataSort.resize(N);
        rIdx.resize(N);
        
        // create a list of indices from 0 to number of events
        // theres is probably astl
        for(int ii = 0; ii < N; ii++)
            rIdx[ii] = ii;
        
        // sort the list of indices using pData
        compare_by_index_stl<T> comp_obj(&rData);
        
        // use stable sort to perserve ordering of equal values, this
        // should be similar to matlab?
        std::sort(rIdx.begin(), rIdx.end(), comp_obj);
        
        for(int ii = 0; ii < N; ii++)
            rDataSort[ii] = rData[rIdx[ii]];
    }
    
    
};

#endif // MEX_ALGORITHM_SUPPORT_H