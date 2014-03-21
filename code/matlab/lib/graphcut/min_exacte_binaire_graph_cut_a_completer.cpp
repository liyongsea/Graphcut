/* MIN_EXACTE_BINAIRE_GRAPH_CUT  algo de Greig
 *
 * Usage: Ir=min_exacte_binaire_graph_cut(I,v1,v2,beta);
 
 */


#include "mex.h"
#include "math.h"

#include "graph.h"
#include "graph.cpp"
#include "maxflow.cpp"


// Terme d'attache aux données
double attache_aux_donnees(double noisy, double reg)
{
  /* a completer par l'energie d'attache aux donnees souhaitee */
    return (noisy-reg)*(noisy-reg) ;
}


// Message d'erreur
void error_msg(char * msg)
{
    mexWarnMsgTxt("Erreur!");
    mexWarnMsgTxt("Usage: Ir=min_exacte_binaire_graph_cut(I,v1,v2,beta)");
    mexErrMsgTxt(msg);
}

// Algorithme graph-cut proprement dit
void compute_graph_cut(double * Id, double * Ir, long W, long H, double v1, double v2, double beta)
{

  long Npix=W*H;
  // Fonction à compléter...
    
         
  /* Allocation du graphe */
     // instancier un objet de type graphe
  //Graph g(Npix,2*Npix,error_msg);
  
  // ou
  Graph* g = new Graph(Npix,2*Npix,error_msg);
    if(g==NULL)
        error_msg("Memory allocation for the graph failed!");
     

    // allouer le tableau d'identifiants de noeuds
    Graph::node_id *nodes=new Graph::node_id[Npix];
    if(nodes==NULL)
        error_msg("Memory allocation failed! (array of nodes could not be created)");
  
    
        
  /* Construction du graphe */
    
    // Création des noeuds
    for(long i=0; i<Npix; i++)
        nodes[i]=g->add_node();

        
    
    // Création des arcs
    for(long i=0; i<W; i++)
    {
        long offset=i*H;
        for(long j=0; j<H; j++)
        {
            long pix=offset+j; // coordonnée linéaire du pixel courant
            
            // Termes d'attache aux données
            double E1=attache_aux_donnees(Id[pix],v1);    // -log vraisemblance de v1
            double E2=attache_aux_donnees(Id[pix],v2);    // -log vraisemblance de v2
            
            g->add_tweights(nodes[pix],E2,E1);

            // Termes de régularisation
            if(j<H-1)
                g->add_edge(nodes[pix],nodes[pix+1],beta,beta);
            if(i<W-1)
                g->add_edge(nodes[pix],nodes[pix+W],beta,beta);
        }
    }
    
        
  /* Calcul de la coupe minimale */
    g->maxflow();
    
    
    
  /* Déduction de l'image régularisée */
    for(long pix=0; pix<Npix; pix++)
    {
        // si le noeud n'est plus relié à la source, c'est qu'il faut associer
        // la valeur 1 au pixel correspondant dans l'image régularisée
        if(g->what_segment(nodes[pix])!=(Graph::SOURCE))
            Ir[pix]=1;
        else
            Ir[pix]=0;
    }


    
  /* Libération mémoire */
    
    delete g;
    delete nodes;


}


// Fonction principale (gère la liaison avec Matlab)
void mexFunction(int nlhs, mxArray *plhs[], int nrhs,
const mxArray *prhs[])
{
  /* Vérification du nombre d'arguments */
    if ( nrhs != 4 ) {
        error_msg("Nombre d'arguments d'entrée incorrect!");
    } else if ((nlhs != 1)) {
        error_msg("Nombre d'arguments de sortie incorrect!");
    }
    
  /* Vérification du type des arguments */
    if (!mxIsDouble(prhs[0])||mxIsComplex(prhs[0])||
    !mxIsDouble(prhs[1])||mxIsComplex(prhs[1])||mxGetM(prhs[1])!=1||mxGetN(prhs[1])!=1||
    !mxIsDouble(prhs[2])||mxIsComplex(prhs[2])||mxGetM(prhs[2])!=1||mxGetN(prhs[2])!=1||
    !mxIsDouble(prhs[3])||mxIsComplex(prhs[3])||mxGetM(prhs[3])!=1||mxGetN(prhs[3])!=1
    ) {
        error_msg("Mauvais type d'argument!");
    }
    
    long W,H;
    W = mxGetM(prhs[0]);
    H = mxGetN(prhs[0]);
    
  /* On récupère les paramètres scalaires */
    double beta,v1,v2;
    beta=*mxGetPr(prhs[3]);
    v1=*mxGetPr(prhs[1]);
    v2=*mxGetPr(prhs[2]);
    
  /* On crée l'image de sortie */
    plhs[0] = mxCreateDoubleMatrix(W,H, mxREAL);
    
  /* On récupère les adresses des matrices d'entrée et de sortie */
    double *Id, *Ir;
    
    Id = mxGetPr(prhs[0]);
    Ir = mxGetPr(plhs[0]);
    
    compute_graph_cut(Id,Ir,W,H,v1,v2,beta);
}
